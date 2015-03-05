#
# Cookbook Name:: hadoop
# Recipe:: hadoop_hdfs_namenode
#
# Copyright © 2013-2015 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'hadoop::default'
include_recipe 'hadoop::_hadoop_hdfs_checkconfig'
include_recipe 'hadoop::_system_tuning'
pkg = 'hadoop-hdfs-namenode'

package pkg do
  action :nothing
end

# Hack to prevent auto-start of services, see COOK-26
ruby_block "package-#{pkg}" do
  block do
    begin
      Chef::Resource::RubyBlock.send(:include, Hadoop::Helpers)
      policy_rcd('disable') if node['platform_family'] == 'debian'
      resources("package[#{pkg}]").run_action(:install)
    ensure
      policy_rcd('enable') if node['platform_family'] == 'debian'
    end
  end
end

dfs_name_dirs =
  if node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.namenode.name.dir')
    node['hadoop']['hdfs_site']['dfs.namenode.name.dir']
  elsif node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.name.dir')
    node['hadoop']['hdfs_site']['dfs.name.dir']
  else
    'file:///tmp/hadoop-hdfs/dfs/name'
  end

node.default['hadoop']['hdfs_site']['dfs.namenode.name.dir'] = dfs_name_dirs

dfs_name_dirs.split(',').each do |dir|
  directory dir.gsub('file://', '') do
    mode '0700'
    owner 'hdfs'
    group 'hdfs'
    action :create
    recursive true
  end
end

# Are we HA?
if node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.ha.automatic-failover.enabled') &&
   node['hadoop']['hdfs_site']['dfs.ha.automatic-failover.enabled'].to_s == 'true'
  include_recipe 'hadoop::hadoop_hdfs_ha_checkconfig'
  include_recipe 'hadoop::hadoop_hdfs_zkfc'

  execute 'hdfs-namenode-bootstrap-standby' do
    command 'hdfs namenode -bootstrapStandby'
    action :nothing
    group 'hdfs'
    user 'hdfs'
  end

  execute 'hdfs-namenode-initialize-sharededits' do
    command 'hdfs namenode -initializeSharedEdits'
    action :nothing
    group 'hdfs'
    user 'hdfs'
  end
end

execute 'hdfs-namenode-format' do
  command 'hdfs namenode -format -nonInteractive' + (node['hadoop']['force_format'] ? ' -force' : '')
  action :nothing
  group 'hdfs'
  user 'hdfs'
end

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

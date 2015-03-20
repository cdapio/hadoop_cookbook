#
# Cookbook Name:: hadoop
# Recipe:: hadoop_hdfs_datanode
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
pkg = 'hadoop-hdfs-datanode'

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

dfs_data_dirs =
  if node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.datanode.data.dir')
    node['hadoop']['hdfs_site']['dfs.datanode.data.dir']
  elsif node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.data.dir')
    node['hadoop']['hdfs_site']['dfs.data.dir']
  else
    'file:///tmp/hadoop-hdfs/dfs/data'
  end

dfs_data_dir_perm =
  if node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.datanode.data.dir.perm')
    node['hadoop']['hdfs_site']['dfs.datanode.data.dir.perm']
  elsif node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.data.dir.perm')
    node['hadoop']['hdfs_site']['dfs.data.dir.perm']
  else
    '0700'
  end

node.default['hadoop']['hdfs_site']['dfs.datanode.data.dir'] = dfs_data_dirs
node.default['hadoop']['hdfs_site']['dfs.datanode.data.dir.perm'] = dfs_data_dir_perm

dfs_data_dirs.split(',').each do |dir|
  directory dir.gsub('file://', '') do
    mode dfs_data_dir_perm
    owner 'hdfs'
    group 'hdfs'
    action :create
    recursive true
  end
end

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

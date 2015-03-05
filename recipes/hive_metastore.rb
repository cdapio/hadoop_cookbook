#
# Cookbook Name:: hadoop
# Recipe:: hive_metastore
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

include_recipe 'hadoop::hive'
include_recipe 'hadoop::_system_tuning'
pkg = 'hive-metastore'

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

# Hive HDFS directories
dfs = node['hadoop']['core_site']['fs.defaultFS']
warehouse_dir =
  if node['hive'].key?('hive_site') && node['hive']['hive_site'].key?('hive.metastore.warehouse.dir')
    node['hive']['hive_site']['hive.metastore.warehouse.dir']
  else
    '/user/hive/warehouse'
  end

scratch_dir =
  if node['hive'].key?('hive_site') && node['hive']['hive_site'].key?('hive.exec.scratchdir')
    node['hive']['hive_site']['hive.exec.scratchdir']
  else
    '/tmp/hive-${user.name}'
  end

node.default['hive']['hive_site']['hive.exec.scratchdir'] = scratch_dir
node.default['hive']['hive_site']['hive.metastore.warehouse.dir'] = warehouse_dir

unless scratch_dir == '/tmp/hive-${user.name}'
  execute 'hive-hdfs-scratchdir' do
    command "hdfs dfs -mkdir -p #{dfs}/#{scratch_dir} && hdfs dfs -chown hive:hive #{dfs}/#{scratch_dir} && hdfs dfs -chmod 777 #{dfs}/#{scratch_dir}"
    timeout 300
    user 'hdfs'
    group 'hdfs'
    not_if "hdfs dfs -test -d #{dfs}/#{scratch_dir}", :user => 'hdfs'
    action :nothing
  end
end

execute 'hive-hdfs-warehousedir' do
  command "hdfs dfs -mkdir -p #{dfs}/#{warehouse_dir} && hdfs dfs -chown hive:hive #{dfs}/#{warehouse_dir} && hdfs dfs -chmod 1777 #{dfs}/#{warehouse_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{dfs}/#{warehouse_dir}", :user => 'hdfs'
  action :nothing
end

template "/etc/init.d/#{pkg}" do
  source "#{pkg}.erb"
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  only_if { node['hadoop']['distribution'] == 'hdp' }
end

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

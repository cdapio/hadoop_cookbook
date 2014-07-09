#
# Cookbook Name:: hadoop
# Recipe:: hive_metastore
#
# Copyright (C) 2013-2014 Continuuity, Inc.
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

package 'hive-metastore' do
  action :install
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
    command "hdfs dfs -mkdir -p #{dfs}/#{scratch_dir} && hdfs dfs -chown hive:hdfs #{dfs}/#{scratch_dir} && hdfs dfs -chmod 777 #{dfs}/#{scratch_dir}"
    timeout 300
    user 'hdfs'
    group 'hdfs'
    not_if "hdfs dfs -test -d #{dfs}/#{scratch_dir}", :user => 'hdfs'
    action :nothing
  end
end

execute 'hive-hdfs-warehousedir' do
  command "hdfs dfs -mkdir -p #{dfs}/#{warehouse_dir} && hdfs dfs -chown hive:hdfs #{dfs}/#{warehouse_dir} && hdfs dfs -chmod 1777 #{dfs}/#{warehouse_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{dfs}/#{warehouse_dir}", :user => 'hdfs'
  action :nothing
end

service 'hive-metastore' do
  status_command 'service hive-metastore status'
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

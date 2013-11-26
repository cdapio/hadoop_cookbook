#
# Cookbook Name:: hadoop
# Recipe:: hadoop_hdfs_datanode
#
# Copyright (C) 2013 Continuuity, Inc.
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
include_recipe 'hadoop::hadoop_hdfs_checkconfig'

package "hadoop-hdfs-datanode" do
  action :install
end

dfs_data_dirs =
  if (node['hadoop'].has_key? 'hdfs_site' and node['hadoop']['hdfs_site'].has_key? 'dfs.data.dir')
    node['hadoop']['hdfs_site']['dfs.data.dir']
  else
    "#{node['hadoop']['core_site']['hadoop.tmp.dir']}/hadoop-hdfs/dfs/data"
  end

dfs_data_dirs.split(',').each do |dir|
  directory dir do
    mode 0755
    owner "hdfs"
    group "hdfs"
    action :create
    recursive true
  end
end

service "hadoop-hdfs-datanode" do
  action :nothing
end

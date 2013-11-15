#
# Cookbook Name:: hadoop
# Recipe:: hbase_checkconfig
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

# We need dfs.datanode.max.xcievers >= 4096
# http://hbase.apache.org/book/configuration.html#hadoop
if (node['hadoop'].has_key? 'hdfs_site' \
  and node['hadoop']['hdfs_site'].has_key? 'dfs.datanode.max.xcievers' \
  and node['hadoop']['hdfs_site']['dfs.datanode.max.xcievers'].to_i >= 4096)
  Chef::Log.info("Set dfs.datanode.max.xcievers to #{node['hadoop']['hdfs_site']['dfs.datanode.max.xcievers']}")
else
  Chef::Application.fatal!("You *must* set node['hadoop']['hdfs_site']['dfs.datanode.max.xcievers'] >= 4096 for HBase")
end

# HBase needs hbase.rootdir and hbase.zookeeper.quorum
if (node['hbase'].has_key? 'hbase_site' \
  and node['hbase']['hbase_site'].has_key? 'hbase.rootdir' \
  and node['hbase']['hbase_site'].has_key? 'hbase.zookeeper.quorum')
  Chef::Log.info("HBase root: #{node['hbase']['hbase_site']['hbase.rootdir']}")
  Chef::Log.info("ZooKeeper Quorum: #{node['hbase']['hbase_site']['hbase.zookeeper.quorum']}")
else
  Chef::Application.fatal!("You *must* set node['hbase']['hbase_site']['hbase.rootdir'] and node['hbase']['hbase_site']['hbase.zookeeper.quorum']")
end

#
# Cookbook Name:: hadoop
# Recipe:: _hbase_checkconfig
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

# We need dfs.datanode.max.transfer.threads >= 4096
# http://hbase.apache.org/book/configuration.html#hadoop
if node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.datanode.max.transfer.threads') &&
   node['hadoop']['hdfs_site']['dfs.datanode.max.transfer.threads'].to_i >= 4096
  Chef::Log.info("Set dfs.datanode.max.transfer.threads to #{node['hadoop']['hdfs_site']['dfs.datanode.max.transfer.threads']}")
elsif node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.datanode.max.xcievers') &&
      node['hadoop']['hdfs_site']['dfs.datanode.max.xcievers'].to_i >= 4096
  Chef::Log.info("Set dfs.datanode.max.transfer.threads to #{node['hadoop']['hdfs_site']['dfs.datanode.max.xcievers']}")
  Chef::Log.warn('dfs.datanode.max.xcievers is deprecated, use dfs.datanode.max.transfer.threads, instead')
  node.default['hadoop']['hdfs_site']['dfs.datanode.max.transfer.threads'] = node['hadoop']['hdfs_site']['dfs.datanode.max.xcievers']
else
  Chef::Application.fatal!("You *must* set node['hadoop']['hdfs_site']['dfs.datanode.max.transfer.threads'] >= 4096 for HBase")
end

# HBase needs hbase.rootdir and hbase.zookeeper.quorum in distributed mode
if node['hbase'].key?('hbase_site') && node['hbase']['hbase_site'].key?('hbase.cluster.distributed') &&
   node['hbase']['hbase_site']['hbase.cluster.distributed'].to_s == 'true'
  if node['hbase'].key?('hbase_site') && node['hbase']['hbase_site'].key?('hbase.rootdir') && node['hbase']['hbase_site'].key?('hbase.zookeeper.quorum')
    Chef::Log.info("HBase root: #{node['hbase']['hbase_site']['hbase.rootdir']}")
    Chef::Log.info("HBase ZooKeeper Quorum: #{node['hbase']['hbase_site']['hbase.zookeeper.quorum']}")
  else
    Chef::Application.fatal!("You *must* set node['hbase']['hbase_site']['hbase.rootdir'] and node['hbase']['hbase_site']['hbase.zookeeper.quorum'] in distributed mode")
  end
end

# If using JAAS, make sure it's configured fully
if node['hbase'].key?('jaas')
  %w(client server).each do |key|
    next unless node['hbase']['jaas'].key?(key) && node['hbase']['jaas'][key].key?('usekeytab') &&
                node['hbase']['jaas'][key]['usekeytab'].to_s == 'true'

    next unless node['hbase']['jaas'][key]['keytab'].nil? || node['hbase']['jaas'][key]['principal'].nil?
    Chef::Application.fatal!("You must set node['hbase']['jaas']['#{key}']['keytab'] and node['hbase']['jaas']['#{key}']['principal'] with node['hbase']['jaas'][key]['usekeytab']")
  end
end

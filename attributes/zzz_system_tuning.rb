#
# Cookbook:: hadoop
# Attribute:: zzz_system_tuning
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

# This attributes file sets up the port reservations for sysctl for COOK-79. Since these values must be compiled into
# a single value, everything is done in this one file, and is done at Chef compile time, versus in a recipe. This is
# to attempt to ensure that the cookbook only gets a single value for this setting on any one cluster.

ports = []

###
# HDFS
###

# fs.defaultFS
ports += if node['hadoop']['core_site'].key?('fs.defaultFS')
           # Embedded in URI? hdfs://hostname:port
           if node['hadoop']['core_site']['fs.defaultFS'].split(':')[2]
             [node['hadoop']['core_site']['fs.defaultFS'].split(':')[2].to_i]
           else
             # Default port for hdfs:// is 8020
             [8020]
           end
         else
           [8020]
         end

# These are all address:port pairs with no protocol prefix specified
# eg. 0.0.0.0:50070
addr_ports = {
  'dfs.namenode.http-address' => 50_070,
  'dfs.namenode.https-address' => 50_470,
  'dfs.datanode.http.address' => 50_075,
  'dfs.datanode.https.address' => 50_475,
  'dfs.namenode.secondary.http-address' => 50_090,
  'dfs.namenode.secondary.https-address' => 50_091,
  'dfs.datanode.address' => 50_010,
  'dfs.datanode.ipc.address' => 50_020,
  'dfs.namenode.backup.address' => 50_100,
  'dfs.namenode.backup.http-address' => 50_105,
  'dfs.journalnode.rpc-address' => 8485,
  'dfs.journalnode.http-address' => 8480,
  'dfs.journalnode.https-address' => 8481,
}

addr_ports.each do |k, v|
  ports += if node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?(k)
             [node['hadoop']['hdfs_site'][k].split(':')[1].to_i]
           else
             [v]
           end
end

###
# MapReduce
###

ports += if node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('mapreduce.jobhistory.webapp.address')
           [node['hadoop']['mapred_site']['mapreduce.jobhistory.webapp.address'].split(':')[1].to_i]
         else
           [19_888]
         end

###
# YARN
###

addr_ports = {
  'yarn.resourcemanager.scheduler.address' => 8030,
  'yarn.resourcemanager.resource-tracker.address' => 8031,
  'yarn.resourcemanager.address' => 8032,
  'yarn.resourcemanager.admin.address' => 8033,
  'yarn.resourcemanager.webapp.address' => 8088,
  'yarn.resourcemanager.webapp.https.address' => 8090,
  'yarn.nodemanager.localizer.address' => 8040,
  'yarn.nodemanager.webapp.address' => 8042,
  'yarn.timeline-service.address' => 10_200,
  'yarn.timeline-service.webapp.address' => 8188,
  'yarn.timeline-service.webapp.https.address' => 8190,
}

addr_ports.each do |k, v|
  ports += if node['hadoop']['yarn_site'].key?('k')
             [node['hadoop']['yarn_site'][k].split(':')[1].to_i]
           else
             [v]
           end
end

###
# HBase
###

addr_ports = {
  'hbase.master.port' => 60_000,
  'hbase.master.info.port' => 60_010,
  'hbase.regionserver.port' => 60_020,
  'hbase.regionserver.info.port' => 60_030,
  'hbase.rest.port' => 8080,
  'hbase.rest.info.port' => 8085,
  'hbase.thrift.port' => 9090,
  'hbase.thrift.info.port' => 9095,
}

addr_ports.each do |k, v|
  ports += if node['hbase']['hbase_site'].key?(k)
             [node['hbase']['hbase_site'][k].to_i]
           else
             [v]
           end
end

###
# Hive
###

if node['hive']['hive_site'].key?('hive.metastore.uris')
  ms_arr = node['hive']['hive_site']['hive.metastore.uris'].split(',')
  ms_arr.each do |ms|
    # thrift://hostname:port
    ports += [ms.split(':')[2].to_i]
  end
end

###
# ZooKeeper
###

ports += if node['zookeeper']['zoocfg'].key?('clientPort')
           [node['zookeeper']['zoocfg']['clientPort'].to_i]
         else
           [2181]
         end

# Ugliness to get peer/leader election ports
1.upto(255) do |index|
  server = node['zookeeper']['zoocfg']["server.#{index}"]
  next if server.nil?
  next unless server.start_with?("#{node['fqdn']}:") || server.start_with?("#{node['ipaddress']}:") || server.start_with?("#{node['hostname']}:")
  ports += [server.split(':')[1].to_i] # Peer port
  ports += [server.split(':')[2].to_i] # Leader election port
  break
end

###
# Finally, set ports
###

ports = ports.uniq.sort.to_s.tr(' ', '').tr('[', '').tr(']', '') # De-dupe, Sort, and Stringify

# net.ipv4.ip_local_reserved_ports setting (COOK-79)
if node.key?('sysctl') && node['sysctl'].key?('params') && node['sysctl']['params'].key?('net') && node['sysctl']['params']['net'].key?('ipv4') &&
   node['sysctl']['params']['net']['ipv4'].key?('ip_local_reserved_ports')
  orig = node['sysctl']['params']['net']['ipv4']['ip_local_reserved_ports']
  default['sysctl']['params']['net']['ipv4']['ip_local_reserved_ports'] = "#{orig},#{ports}"
else
  default['sysctl']['params']['net']['ipv4']['ip_local_reserved_ports'] = ports
end

#
# Cookbook Name:: hadoop
# Recipe:: _hadoop_hdfs_ha_checkconfig
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

# HDFS HA requires dfs.nameservices
if node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.nameservices')
  dfs_nameservices = node['hadoop']['hdfs_site']['dfs.nameservices'].split(',')
else
  Chef::Application.fatal!("HDFS NameNode HA requires node['hadoop']['hdfs_site']['dfs.nameservices'] to be set")
end

# We have dfs.nameservices, and now need to check them
dfs_nameservices.each do |ns|
  # Start namenode checks
  next unless node['hadoop']['hdfs_site'].key?("dfs\.ha\.namenodes\.#{ns}")
  # We need two and only two NameNodes
  namenodes = node['hadoop']['hdfs_site']["dfs\.ha\.namenodes\.#{ns}"].split(',')
  if namenodes.size != 2
    Chef::Application.fatal!("NameNode HA requires exactly two entries in node['hadoop']['hdfs_site']['dfs.ha.namenodes.#{ns}']")
  end
  # Check NameNode-specific entries
  namenodes.each do |nn|
    %w(rpc-address http-address).each do |k|
      if node['hadoop']['hdfs_site'].key?("dfs\.namenode\.#{k}\.#{ns}\.#{nn}")
        Chef::Log.info("Set dfs.namenode.#{k}.#{ns}.#{nn} to #{node['hadoop']['hdfs_site']['dfs.namenode.#{k}.#{ns}.#{nn}']}")
      else
        Chef::Application.fatal!("You must set node['hadoop']['hdfs_site']['dfs.namenode.#{k}.#{ns}.#{nn}']")
      end
    end
  end # End namenode checks
  # Start proxy provider check
  if node['hadoop']['hdfs_site'].key?("dfs\.client\.failover\.proxy\.provider\.#{ns}")
    Chef::Log.info("Using #{node['hadoop']['hdfs_site']['dfs.client.failover.proxy.provider.#{ns}']} for node['hadoop']['hdfs_site']['dfs.client.failover.proxy.provider.#{ns}']")
  else
    node.default['hadoop']['hdfs_site']["dfs\.client\.failover\.proxy\.provider\.#{ns}"] = \
      'org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider'
  end # End proxy provider check
  # Start fs.defaultFS check
  next if node['hadoop']['hdfs_site']['fs.defaultFS'] == "hdfs://#{ns}"
  Chef::Application.fatal!("HA requires node['hadoop']['hdfs_site']['fs.defaultFS'] to be 'hdfs://#{ns}'")
end

# dfs.namenode.shared.edits.dir format: "qjournal://host1:port1;host2:port2;host3:port3/journalId" or "file:///path/to/mount"
if node['hadoop']['hdfs_site'].key?('dfs.namenode.shared.edits.dir')
  if node['hadoop']['hdfs_site']['dfs.namenode.shared.edits.dir'].start_with?('qjournal')
    # Start journalnode checks
    journalnodes = node['hadoop']['hdfs_site']['dfs.namenode.shared.edits.dir'].split(';')
    # We need 3+ JournalNodes
    if journalnodes.size < 3
      Chef::Application.fatal!('You must have at least 3 JournalNodes configured for HDFS HA')
    end # End journalnode checks
  elsif node['hadoop']['hdfs_site']['dfs.namenode.shared.edits.dir'].start_with?('file')
    # Start NFS/Shared-storage checks
    nfsdir = node['hadoop']['hdfs_site']['dfs.namenode.shared.edits.dir']
    unless File.directory?(nfsdir)
      Chef::Application.fatal!("Directory #{nfsdir} nonexistant! Check node['hadoop']['hdfs_site']['dfs.namenode.shared.edits.dir'] setting!")
    end
  else
    Chef::Application.fatal!('dfs.namenode.shared.edits.dir supports qjournal or file only')
  end
end

# Start fencing check -- we only check that the key has a value
if node['hadoop']['hdfs_site'].key?('dfs.ha.fencing.methods')
  Chef::Log.info('Using the following HA fencing methods:')
  node['hadoop']['hdfs_site']['dfs.ha.fencing.methods'].split(',').each do |m|
    Chef::Log.info("  #{m}")
  end
else
  Chef::Application.fatal!("You must specify a fencing method for node['hadoop']['hdfs_site']['dfs.ha.fencing.methods']")
end # End fencing check

# Start Automatic HA check
if node['hadoop']['hdfs_site'].key?('dfs.ha.automatic-failover.enabled') && node['hadoop']['hdfs_site']['dfs.ha.automatic-failover.enabled'].to_s == 'true'
  if node['hadoop']['core_site'].key?('ha.zookeeper.quorum')
    ha_zk_quorum = node['hadoop']['core_site']['ha.zookeeper.quorum'].split(',')
    Chef::Log.info("NameNode HA ZooKeeper Quorum: #{ha_zk_quorum}")
  else
    Chef::Application.fatal!("Automatic HA failover requires node['hadoop']['core_site']['ha.zookeeper.quorum'] to be set")
  end
end # End Automatic HA check

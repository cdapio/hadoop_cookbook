# hadoop cookbook

# Requirements

* Chef 11.4.0+
* CentOS 6.4+
* Ubuntu 12.04+

# Usage

# Attributes

## Distribution Attributes

* `['hadoop']['distribution']` - Specifies which Hadoop distribution to use, currently supported: cdh, hdp. Default `hdp`
* `['hadoop']['yum_repo_url']` - Provide an alternate yum installation source location. If you change this attribute, you are expected to provide a path to a working repo for the `node['hadoop']['distribution']` used. Default: `nil`
* `['hadoop']['yum_repo_key_url']` - Provide an alternative yum repository key source location. Default `nil`

## Global Configuration Attributes

* `['hadoop']['conf_dir']` - The directory used inside `/etc/hadoop` and used via the alternatives system. Default `conf.chef`
* `['hbase']['conf_dir']` - The directory used inside `/etc/hbase` and used via the alternatives system. Default `conf.chef`
* `['zookeeper']['conf_dir']` - The directory used inside `/etc/zookeeper` and used via the alternatives system. Default `conf.chef`

# Recipes

* `default.rb` - Sets up configuration and `hadoop-client` packages.
* `hadoop_hdfs_checkconfig` - Ensures the HDFS configuration meets required parameters.
* `hadoop_hdfs_datanode` - Sets up an HDFS DataNode.
* `hadoop_hdfs_ha_checkconfig` - Ensures the HDFS configuration meets requirements for High Availability.
* `hadoop_hdfs_journalnode` - Sets up an HDFS JournalNode.
* `hadoop_hdfs_namenode` - Sets up an HDFS NameNode.
* `hadoop_hdfs_secondarynamenode` - Sets up an HDFS Secondary NameNode.
* `hadoop_yarn_nodemanager` - Sets up a YARN NodeManager.
* `hadoop_yarn_resourcemanager` - Sets up a YARN ResourceManager.
* `hbase` - Sets up configuration and `hbase` packages.
* `hbase_checkconfig` - Ensures the HBase configuration meets required parameters.
* `hbase_master` - Sets up an HBase Master.
* `hbase_regionserver` - Sets up an HBase RegionServer.
* `hbase_thrift` - Sets up an HBase Thrift interface.
* `repo` - Sets up package manager repositories for specified `node['hadoop']['distribution']`
* `zookeeper` - Sets up `zookeeper` package.
* `zookeeper_server` - Sets up a ZooKeeper server.

# Author

Author:: Chris Gianelloni (<chris@continuuity.com>)

Author:: Continuuity, Inc. (<ops@continuuity.com>)

# Testing

This cookbook requires the `vagrant-omnibus` and `vagrant-berkshelf` Vagrant plugins to be installed.

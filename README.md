# hadoop cookbook

[![Cookbook Version](http://img.shields.io/cookbook/v/hadoop.svg)](https://community.opscode.com/cookbooks/hadoop)
[![Build Status](http://img.shields.io/travis/continuuity/hadoop_cookbook.svg)](http://travis-ci.org/continuuity/hadoop_cookbook)

# Requirements

This cookbook may work on earlier versions, but these are the minimal tested versions.

* Chef 11.4.0+
* CentOS 6.4+
* Ubuntu 12.04+

This cookbook assumes that you have a working Java installation. It has been tested using version `1.21.2` of the `java` cookbook, using Oracle Java 6. If you plan on using Hive with a database other than the embedded Derby, you will need to provide it and set it up prior to starting Hive Metastore service.

# Usage

This cookbook is designed to be used with a wrapper cookbook or a role with settings for configuring Hadoop. The services should work out of the box on a single host, but little validation is done that you have made a working Hadoop configuration. The cookbook is attribute-driven and is suitable for use via either `chef-client` or `chef-solo` since it does not use any server-based functionality. The cookbook defines service definitions for each Hadoop service, but it does not enable or start them, by default.

For more information, read the [Wrapping this cookbook](https://github.com/continuuity/hadoop_cookbook/wiki/Wrapping-this-cookbook) wiki entry.

# Attributes

Attributes for this cookbook define the configuration files for Hadoop and its various services. Hadoop configuration files are XML files, with name/value property pairs. The attribute name determines which file the property is placed and the property name. The attribute value is the property value. The attribute `hadoop['core_site']['fs.defaultFS']` will configure a property named `fs.defaultFS` in `core-site.xml` in `hadoop['conf_dir']`. All attribute values are taken as-is and only minimal configuration checking is done on values. It is up to the user to provide a valid configuration for your cluster.

Attribute Tree | File | Location 
-------------- | ---- | --------
hadoop['capacity_scheduler'] | capacity-scheduler.xml | `hadoop['conf_dir']`
hadoop['container_executor'] | container-executor.cfg | `hadoop['conf_dir']`
hadoop['core_site'] | core-site.xml | `hadoop['conf_dir']`
hadoop['fair_scheduler'] | fair-scheduler.xml | `hadoop['conf_dir']`
hadoop['hadoop_env'] | hadoop-env.sh | `hadoop['conf_dir']`
hadoop['hadoop_metrics'] | hadoop-metrics.properties | `hadoop['conf_dir']`
hadoop['hadoop_policy'] | hadoop-policy.xml | `hadoop['conf_dir']`
hadoop['hdfs_site'] | hdfs-site.xml | `hadoop['conf_dir']`
hadoop['log4j'] | log4j.properties | `hadoop['conf_dir']`
hadoop['mapred_site'] | mapred-site.xml | `hadoop['conf_dir']`
hadoop['yarn_env'] | yarn-env.sh | `hadoop['conf_dir']`
hadoop['yarn_site'] | yarn-site.xml | `hadoop['conf_dir']`
hbase['hadoop_metrics'] | hadoop-metrics.properties | `hbase['conf_dir']`
hbase['hbase_env'] | hbase-env.sh | `hbase['conf_dir']`
hbase['hbase_policy'] | hbase-policy.xml | `hbase['conf_dir']`
hbase['hbase_site'] | hbase-site.xml | `hbase['conf_dir']`
hbase['log4j'] | log4j.properties | `hbase['conf_dir']`
hive['hive_env'] | hive-env.sh | `hive['conf_dir']`
hive['hive_site'] | hive-site.xml | `hive['conf_dir']`
oozie['oozie_site'] | oozie-site.xml | `oozie['conf_dir']`
zookeeper['log4j'] | log4j.properties | `zookeeper['conf_dir']`
zookeeper['zoocfg'] | zoo.cfg | `zookeeper['conf_dir']`

## Distribution Attributes

* `hadoop['distribution']` - Specifies which Hadoop distribution to use, currently supported: cdh, hdp. Default `hdp`
* `hadoop['distribution_version']` - Specifies which version of `hadoop['distribution']` to use. Default `2.0` if `hadoop['distribution']` is `hdp` and `5` if `hadoop['distribution']` is `cdh`

### APT-specific settings

* `hadoop['apt_repo_url']` - Provide an alternate apt installation source location. If you change this attribute, you are expected to provide a path to a working repo for the `hadoop['distribution']` used. Default: `nil`
* `hadoop['apt_repo_key_url']` - Provide an alternative apt repository key source location. Default `nil`

### RPM-specific settings

* `hadoop['yum_repo_url']` - Provide an alternate yum installation source location. If you change this attribute, you are expected to provide a path to a working repo for the `hadoop['distribution']` used. Default: `nil`
* `hadoop['yum_repo_key_url']` - Provide an alternative yum repository key source location. Default `nil`

## Global Configuration Attributes

* `hadoop['conf_dir']` - The directory used inside `/etc/hadoop` and used via the alternatives system. Default `conf.chef`
* `hbase['conf_dir']` - The directory used inside `/etc/hbase` and used via the alternatives system. Default `conf.chef`
* `hive['conf_dir']` - The directory used inside `/etc/hive` and used via the alternatives system. Default `conf.chef`
* `oozie['conf_dir']` - The directory used inside `/etc/oozie` and used via the alternatives system. Default `conf.chef`
* `zookeeper['conf_dir']` - The directory used inside `/etc/zookeeper` and used via the alternatives system. Default `conf.chef`

## Default Attributes

* `hadoop['core_site']['fs.defaultFS']` - Sets URI to HDFS NameNode. Default `hdfs://localhost`
* `hadoop['yarn_site']['yarn.resourcemanager.hostname']` - Sets hostname of YARN ResourceManager. Default `localhost`
* `hive['hive_site']['javax.jdo.option.ConnectionURL']` - Sets JDBC URL. Default `jdbc:derby:;databaseName=/var/lib/hive/metastore/metastore_db;create=true`
* `hive['hive_site']['javax.jdo.option.ConnectionDriverName']` - Sets JDBC Driver. Default `org.apache.derby.jdbc.EmbeddedDriver`

# Recipes

* `default.rb` - Sets up configuration and `hadoop-client` packages.
* `hadoop_hdfs_checkconfig` - Ensures the HDFS configuration meets required parameters.
* `hadoop_hdfs_datanode` - Sets up an HDFS DataNode.
* `hadoop_hdfs_ha_checkconfig` - Ensures the HDFS configuration meets requirements for High Availability.
* `hadoop_hdfs_journalnode` - Sets up an HDFS JournalNode.
* `hadoop_hdfs_namenode` - Sets up an HDFS NameNode.
* `hadoop_hdfs_secondarynamenode` - Sets up an HDFS Secondary NameNode.
* `hadoop_hdfs_zkfc` - Sets up HDFS Failover Controller, required for automated NameNode failover.
* `hadoop_yarn_nodemanager` - Sets up a YARN NodeManager.
* `hadoop_yarn_proxyserver` - Sets up a YARN Web Proxy.
* `hadoop_yarn_resourcemanager` - Sets up a YARN ResourceManager.
* `hbase` - Sets up configuration and `hbase` packages.
* `hbase_checkconfig` - Ensures the HBase configuration meets required parameters.
* `hbase_master` - Sets up an HBase Master.
* `hbase_regionserver` - Sets up an HBase RegionServer.
* `hbase_rest` - Sets up an HBase REST interface.
* `hbase_thrift` - Sets up an HBase Thrift interface.
* `hive` - Sets up configuration and `hive` packages.
* `hive_metastore` - Sets up Hive Metastore metadata repository.
* `hive_server` - Sets up a Hive Thrift service.
* `hive_server2` - Sets up a Hive Thrift service with Kerberos and multi-client concurrency support.
* `oozie` - Sets up an Oozie server.
* `oozie_client` - Sets up an Oozie client.
* `pig` - Installs pig interpreter.
* `repo` - Sets up package manager repositories for specified `hadoop['distribution']`
* `zookeeper` - Sets up `zookeeper` package.
* `zookeeper_server` - Sets up a ZooKeeper server.

# Author

Author:: Continuuity, Inc. (<ops@continuuity.com>)

# Testing

This cookbook has several ways to test it. It includes code tests, which are done using `foodcritic`, `rubocop`, and `chefspec`.
It, also, includes functionality testing, provided by `vagrant`.

```text
rake foodcritic
rake rubocop
rake chefspec
rake vagrant
```

This cookbook requires the `vagrant-omnibus` and `vagrant-berkshelf` Vagrant plugins to be installed.

# License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this software except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

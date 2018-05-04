name             'hadoop'
maintainer       'Cask Data, Inc.'
maintainer_email 'ops@cask.co'
license          'Apache-2.0'
description      'Installs/Configures Hadoop (HDFS/YARN/MRv2), HBase, Hive, Flume, Oozie, Pig, Spark, Storm, Tez, and ZooKeeper'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.14.0'

depends 'yum', '>= 3.0'
depends 'apt', '>= 2.1.2'

%w(dpkg_autostart selinux sysctl ulimit).each do |cb|
  depends cb
end

# RHEL-like distributions
%w(
  centos
  redhat
  scientific
).each do |os|
  supports os, '>= 6.0'
end

%w(
  amazon
  debian
  ubuntu
).each do |os|
  supports os
end

source_url 'https://github.com/caskdata/hadoop_cookbook' if respond_to?(:source_url)
issues_url 'https://issues.cask.co/browse/COOK/component/10600' if respond_to?(:issues_url)
chef_version '>= 11' if respond_to?(:chef_version)

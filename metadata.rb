name             'hadoop'
maintainer       'Continuuity, Inc.'
maintainer_email 'ops@continuuity.com'
license          'Apache 2.0'
description      'Installs/Configures Hadoop (HDFS/YARN/MRv2), HBase, Hive, Oozie, Pig, and ZooKeeper'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.7'

depends 'yum', '>= 3.0'
depends 'apt'

%w(centos debian redhat scientific ubuntu).each do |os|
  supports os
end

%w(hadoop_cluster hadoop_cluster_rpm hadoop_for_hbase hbase hbase_cluster hive pig zookeeper zookeeper_cluster).each do |cb|
  conflicts cb
end

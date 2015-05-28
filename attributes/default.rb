###
# cookbook settings
###
# Supported: cdh, hdp, bigtop
default['hadoop']['distribution'] = 'hdp'

default['hadoop']['force_format'] = false

# Default: conf.chef
default['hadoop']['conf_dir'] = 'conf.chef'
default['flume']['conf_dir'] = node['hadoop']['conf_dir']
default['hbase']['conf_dir'] = node['hadoop']['conf_dir']
default['hive']['conf_dir'] = node['hadoop']['conf_dir']
default['oozie']['conf_dir'] = node['hadoop']['conf_dir']
default['spark']['conf_dir'] = node['hadoop']['conf_dir']
default['tez']['conf_dir'] = node['hadoop']['conf_dir']
default['zookeeper']['conf_dir'] = node['hadoop']['conf_dir']

# limits.d settings
default['hadoop']['limits']['nofile'] = '32768'
default['hadoop']['limits']['nproc'] = '65536'

###
# core-site.xml settings
###
default['hadoop']['core_site']['fs.defaultFS'] = "hdfs://#{node['fqdn']}"

###
# yarn-site.xml settings
###
default['hadoop']['yarn_site']['yarn.resourcemanager.hostname'] = node['fqdn']

# Set yarn.application.classpath
if node['hadoop']['distribution'] == 'hdp' && node['hadoop']['distribution_version'].to_f >= 2.2
  default['hadoop']['yarn_site']['yarn.application.classpath'] = '/etc/hadoop/conf,/usr/hdp/${hdp.version}/hadoop-client/*,/usr/hdp/${hdp.version}/hadoop-client/lib/*,/usr/hdp/${hdp.version}/hadoop-hdfs-client/*,/usr/hdp/${hdp.version}/hadoop-hdfs-client/lib/*,/usr/hdp/${hdp.version}/hadoop-yarn-client/*,/usr/hdp/${hdp.version}/hadoop-yarn-client/lib/*'
else
  default['hadoop']['yarn_site']['yarn.application.classpath'] = '$HADOOP_CONF_DIR, $HADOOP_COMMON_HOME/*, $HADOOP_COMMON_HOME/lib/*, $HADOOP_HDFS_HOME/*, $HADOOP_HDFS_HOME/lib/*, $HADOOP_MAPRED_HOME/*, $HADOOP_MAPRED_HOME/lib/*, $HADOOP_YARN_HOME/*, $HADOOP_YARN_HOME/lib/*'
end

###
# MR settings for HDP 2.2+
###
if node['hadoop']['distribution'] == 'hdp' && node['hadoop']['distribution_version'].to_f >= 2.2
  default['hadoop']['mapred_site']['mapreduce.admin.map.child.java.opts'] = '-server -Djava.net.preferIPv4Stack=true -Dhdp.version=${hdp.version}'
  default['hadoop']['mapred_site']['mapreduce.admin.user.env'] = 'LD_LIBRARY_PATH=/usr/hdp/${hdp.version}/hadoop/lib/native:/usr/hdp/${hdp.version}/hadoop/lib/native/Linux-amd64-64'
  default['hadoop']['mapred_site']['mapreduce.application.framework.path'] = '/hdp/apps/${hdp.version}/mapreduce/mapreduce.tar.gz#mr-framework'
  default['hadoop']['mapred_site']['mapreduce.application.classpath'] = '$PWD/mr-framework/hadoop/share/hadoop/mapreduce/*:$PWD/mr-framework/hadoop/share/hadoop/mapreduce/lib/*:$PWD/mr-framework/hadoop/share/hadoop/common/*:$PWD/mr-framework/hadoop/share/hadoop/common/lib/*:$PWD/mr-framework/hadoop/share/hadoop/yarn/*:$PWD/mr-framework/hadoop/share/hadoop/yarn/lib/*:$PWD/mr-framework/hadoop/share/hadoop/hdfs/*:$PWD/mr-framework/hadoop/share/hadoop/hdfs/lib/*:/usr/hdp/${hdp.version}/hadoop/lib/hadoop-lzo-0.6.0.${hdp.version}.jar:/etc/hadoop/conf/secure'
end

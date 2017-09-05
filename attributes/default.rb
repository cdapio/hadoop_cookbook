#
# Cookbook:: hadoop
# Attribute:: default
#
# Copyright © 2013-2016 Cask Data, Inc.
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

###
# cookbook settings
###
# Supported: cdh, hdp, bigtop, iop
default['hadoop']['distribution'] = 'hdp'

# Set defaults for version, based on distribution
default['hadoop']['distribution_version'] =
  if node['hadoop'].key?('distribution_version')
    node['hadoop']['distribution_version']
  elsif node['hadoop']['distribution'] == 'hdp'
    '2.4.3.0'
  elsif node['hadoop']['distribution'] == 'cdh'
    '5.7.3'
  elsif node['hadoop']['distribution'] == 'bigtop'
    '1.0.0'
  elsif node['hadoop']['distribution'] == 'iop'
    '4.1.0.0'
  end

default['hadoop']['force_format'] = false

# Default: conf.chef
default['hadoop']['conf_dir'] = 'conf.chef'
default['flume']['conf_dir'] = node['hadoop']['conf_dir']
default['hadoop_kms']['conf_dir'] = node['hadoop']['conf_dir']
default['hbase']['conf_dir'] = node['hadoop']['conf_dir']
default['hive']['conf_dir'] = node['hadoop']['conf_dir']
default['hive2']['conf_dir'] = node['hadoop']['conf_dir']
default['oozie']['conf_dir'] = node['hadoop']['conf_dir']
default['spark']['conf_dir'] = node['hadoop']['conf_dir']
default['spark2']['conf_dir'] = node['hadoop']['conf_dir']
default['storm']['conf_dir'] = node['hadoop']['conf_dir']
default['tez']['conf_dir'] = node['hadoop']['conf_dir']
default['zookeeper']['conf_dir'] = node['hadoop']['conf_dir']

# limits.d settings
default['hadoop']['limits']['nofile'] = '32768'
default['hadoop']['limits']['nproc'] = '65536'

# net.ipv4.ip_local_reserved_ports setting (COOK-79)
default['hadoop']['sysctl']['net.ipv4.ip_local_reserved_ports'] = []

###
# core-site.xml settings
###
default['hadoop']['core_site']['fs.defaultFS'] = "hdfs://#{node['fqdn']}"

###
# yarn-site.xml settings
###
default['hadoop']['yarn_site']['yarn.resourcemanager.hostname'] = node['fqdn']
default['hadoop']['yarn_site']['yarn.scheduler.increment-allocation-vcores'] = '1'

# Ensure yarn.scheduler.minimum-allocation-mb >= yarn.scheduler.increment-allocation-mb
default['hadoop']['yarn_site']['yarn.scheduler.minimum-allocation-mb'] = '1024'
default['hadoop']['yarn_site']['yarn.scheduler.increment-allocation-mb'] =
  if node['hadoop']['yarn_site']['yarn.scheduler.minimum-allocation-mb'].to_i < 1024
    node['hadoop']['yarn_site']['yarn.scheduler.minimum-allocation-mb']
  else
    '1024'
  end

# Set yarn.application.classpath
default['hadoop']['yarn_site']['yarn.application.classpath'] =
  if node['hadoop']['distribution'] == 'hdp' && node['hadoop']['distribution_version'].to_f >= 2.2
    '/etc/hadoop/conf,/usr/hdp/current/hadoop-client/*,/usr/hdp/current/hadoop-client/lib/*,/usr/hdp/current/hadoop-hdfs-client/*,/usr/hdp/current/hadoop-hdfs-client/lib/*,/usr/hdp/current/hadoop-yarn-client/*,/usr/hdp/current/hadoop-yarn-client/lib/*'
  else
    '$HADOOP_CONF_DIR, $HADOOP_COMMON_HOME/*, $HADOOP_COMMON_HOME/lib/*, $HADOOP_HDFS_HOME/*, $HADOOP_HDFS_HOME/lib/*, $HADOOP_MAPRED_HOME/*, $HADOOP_MAPRED_HOME/lib/*, $HADOOP_YARN_HOME/*, $HADOOP_YARN_HOME/lib/*'
  end

# Do the right thing, based on distribution
if node['hadoop']['distribution'] == 'cdh' && node['hadoop']['distribution_version'].to_i == 4
  # CDH4 doesn't have https://issues.apache.org/jira/browse/YARN-1229 fixed
  default['hadoop']['yarn_site']['yarn.nodemanager.aux-services'] = 'mapreduce.shuffle'
  default['hadoop']['yarn_site']['yarn.nodemanager.aux-services.mapreduce.shuffle.class'] = 'org.apache.hadoop.mapred.ShuffleHandler'
else
  default['hadoop']['yarn_site']['yarn.nodemanager.aux-services'] = 'mapreduce_shuffle'
  default['hadoop']['yarn_site']['yarn.nodemanager.aux-services.mapreduce_shuffle.class'] = 'org.apache.hadoop.mapred.ShuffleHandler'
end

# MapReduce settings
default['hadoop']['hadoop_env']['hadoop_opts'] = '-Djava.net.preferIPv4Stack=true ${HADOOP_OPTS}'
default['hadoop']['mapred_env']['hadoop_opts'] = '-Djava.net.preferIPv4Stack=true ${HADOOP_OPTS}'

if node['hadoop']['distribution'] == 'iop' ||
   (
     node['hadoop']['distribution'] == 'hdp' &&
     node['hadoop']['distribution_version'].to_f >= 2.2
   )

  distro = node['hadoop']['distribution']
  lzo_jar = distro == 'hdp' ? 'hadoop-lzo-0.6.0.${hdp.version}.jar' : 'hadoop-lzo-0.5.1.jar'
  # %{_FULL_VERSION} will be interpolated in the default recipe, when helper libraries are available
  default['hadoop']['hadoop_env']['hadoop_opts'] += " -D#{distro}.version=%<_FULL_VERSION>s"
  default['hadoop']['mapred_env']['hadoop_opts'] += " -D#{distro}.version=%<_FULL_VERSION>s"
  default['hadoop']['mapred_site']['mapreduce.admin.map.child.java.opts'] =
    "-server -Djava.net.preferIPv4Stack=true -D#{distro}.version=${#{distro}.version}"
  default['hadoop']['mapred_site']['mapreduce.admin.user.env'] =
    "LD_LIBRARY_PATH=/usr/#{distro}/${#{distro}.version}/hadoop/lib/native:/usr/#{distro}/${#{distro}.version}/hadoop/lib/native/Linux-amd64-64"
  default['hadoop']['mapred_site']['mapreduce.application.framework.path'] =
    "/#{distro}/apps/${#{distro}.version}/mapreduce/mapreduce.tar.gz#mr-framework"
  default['hadoop']['mapred_site']['mapreduce.application.classpath'] =
    "$PWD/mr-framework/hadoop/share/hadoop/mapreduce/*:$PWD/mr-framework/hadoop/share/hadoop/mapreduce/lib/*:$PWD/mr-framework/hadoop/share/hadoop/common/*:$PWD/mr-framework/hadoop/share/hadoop/common/lib/*:$PWD/mr-framework/hadoop/share/hadoop/yarn/*:$PWD/mr-framework/hadoop/share/hadoop/yarn/lib/*:$PWD/mr-framework/hadoop/share/hadoop/hdfs/*:$PWD/mr-framework/hadoop/share/hadoop/hdfs/lib/*:/usr/#{distro}/${#{distro}.version}/hadoop/lib/#{lzo_jar}:/etc/hadoop/conf/secure"
  default['hadoop']['mapred_site']['yarn.app.mapreduce.am.admin-command-opts'] =
    "-D#{distro}.version=${#{distro}.version}"
end

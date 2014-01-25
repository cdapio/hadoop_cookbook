###
# cookbook settings
###
# Supported: cdh, hdp
default['hadoop']['distribution'] = 'hdp'
default['hadoop']['distribution_version'] = '2'
# Default: conf.chef
default['hadoop']['conf_dir'] = 'conf.chef'
default['hbase']['conf_dir'] = node['hadoop']['conf_dir']
default['hive']['conf_dir'] = node['hadoop']['conf_dir']
default['oozie']['conf_dir'] = node['hadoop']['conf_dir']
default['zookeeper']['conf_dir'] = node['hadoop']['conf_dir']

###
# core-site.xml settings
###
default['hadoop']['core_site']['fs.defaultFS'] = "hdfs://#{node['fqdn']}"

###
# yarn-site.xml settings
###
default['hadoop']['yarn_site']['yarn.resourcemanager.hostname'] = node['fqdn']

###
# JAVA_HOME
###
if (node.has_key? 'java' and node['java'].has_key? 'java_home')
  default['hadoop']['hadoop_env']['java_home'] = node['java']['java_home']
  default['hbase']['hbase_env']['java_home'] = node['java']['java_home']
  default['hive']['hive_env']['java_home'] = node['java']['java_home']
  default['oozie']['oozie_env']['java_home'] = node['java']['java_home']
end

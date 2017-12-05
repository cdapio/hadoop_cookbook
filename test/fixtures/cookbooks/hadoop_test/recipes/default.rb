# The default sets up HDFS/YARN
include_recipe 'java::default'

if node.key?('java') && node['java'].key?('java_home')

  Chef::Log.info("JAVA_HOME = #{node['java']['java_home']}")

  # set in ruby environment for commands like hdfs namenode -format
  ENV['JAVA_HOME'] = node['java']['java_home']
  # set in hadoop_env
  node.default['hadoop']['hadoop_env']['java_home'] = node['java']['java_home']
  # set in hbase_env
  node.default['hbase']['hbase_env']['java_home'] = node['java']['java_home']
  # set in hive_env
  node.default['hive']['hive_env']['java_home'] = node['java']['java_home']
end

include_recipe 'hadoop_test::hdfs'
include_recipe 'hadoop_test::yarn'

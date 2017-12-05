#
# Cookbook:: hadoop
# Recipe:: hadoop_mapreduce_historyserver
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

include_recipe 'hadoop::default'
pkg = 'hadoop-mapreduce-historyserver'

am_staging_dir =
  if node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('yarn.app.mapreduce.am.staging-dir')
    node['hadoop']['mapred_site']['yarn.app.mapreduce.am.staging-dir']
  else
    '/tmp/hadoop-yarn/staging'
  end

jhs_intermediate_done_dir =
  if node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('mapreduce.jobhistory.intermediate-done-dir')
    node['hadoop']['mapred_site']['mapreduce.jobhistory.intermediate-done-dir']
  else
    "#{am_staging_dir}/history/done_intermediate"
  end

jhs_done_dir =
  if node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('mapreduce.jobhistory.done-dir')
    node['hadoop']['mapred_site']['mapreduce.jobhistory.done-dir']
  else
    "#{am_staging_dir}/history/done"
  end

execute 'mapreduce-jobhistory-intermediate-done-dir' do
  command "hdfs dfs -mkdir -p #{jhs_intermediate_done_dir} && hdfs dfs -chown mapred:hadoop #{jhs_intermediate_done_dir} && hdfs dfs -chmod 1777 #{jhs_intermediate_done_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{jhs_intermediate_done_dir}", user: 'hdfs'
  action :nothing
end

execute 'mapreduce-jobhistory-done-dir' do
  command "hdfs dfs -mkdir -p #{jhs_done_dir} && hdfs dfs -chown mapred:hadoop #{jhs_done_dir} && hdfs dfs -chmod 1777 #{jhs_done_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{jhs_done_dir}", user: 'hdfs'
  action :nothing
end

# Default HADOOP_MAPRED_LOG_DIR
hadoop_log_dir =
  if node['hadoop'].key?('hadoop_env') && node['hadoop']['hadoop_env'].key?('hadoop_mapred_log_dir')
    node['hadoop']['hadoop_env']['hadoop_mapred_log_dir']
  elsif hdp22? || iop?
    '/var/log/hadoop/mapreduce'
  else
    '/var/log/hadoop-mapreduce'
  end

hadoop_pid_dir =
  if hdp22? || iop?
    '/var/run/hadoop/mapreduce'
  else
    '/var/run/hadoop-mapreduce'
  end

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'hadoop_mapred_pid_dir' => hadoop_pid_dir,
    'hadoop_mapred_log_dir' => hadoop_log_dir,
    'hadoop_mapred_ident_string' => 'mapred',
    'hadoop_mapred_home' => "#{hadoop_lib_dir}/hadoop-mapreduce",
    'hadoop_log_dir' => hadoop_log_dir,
  }
end

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'desc' => 'Hadoop MapReduce JobHistory Server',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{hadoop_lib_dir}/hadoop-mapreduce/sbin/mr-jobhistory-daemon.sh",
    'args' => '--config ${CONF_DIR} start historyserver',
    'confdir' => '${HADOOP_CONF_DIR}',
    'user' => 'mapred',
    'home' => "#{hadoop_lib_dir}/hadoop",
    'pidfile' => '${HADOOP_MAPRED_PID_DIR}/mapred-mapred-historyserver.pid',
    'logfile' => "${HADOOP_MAPRED_LOG_DIR}/#{pkg}.log",
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action :nothing
end

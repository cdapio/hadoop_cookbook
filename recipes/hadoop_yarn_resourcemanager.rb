#
# Cookbook:: hadoop
# Recipe:: hadoop_yarn_resourcemanager
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
include_recipe 'hadoop::_system_tuning'
pkg = 'hadoop-yarn-resourcemanager'

# TODO: check for these and set them up
# mapreduce.cluster.local.dir = #{hadoop_tmp_dir}/mapred/local
# mapreduce.cluster.temp.dir = #{hadoop_tmp_dir}/mapred/temp

# We need a /tmp in HDFS
dfs = node['hadoop']['core_site']['fs.defaultFS']
execute 'hdfs-tmpdir' do
  command "hdfs dfs -mkdir -p #{dfs}/tmp && hdfs dfs -chmod 1777 #{dfs}/tmp"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  action :nothing
end

remote_log_dir =
  if node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?('yarn.nodemanager.remote-app-log-dir')
    node['hadoop']['yarn_site']['yarn.nodemanager.remote-app-log-dir']
  else
    '/tmp/logs'
  end

node.default['hadoop']['yarn_site']['yarn.nodemanager.remote-app-log-dir'] = remote_log_dir

execute 'yarn-remote-app-log-dir' do
  command "hdfs dfs -mkdir -p #{remote_log_dir} && hdfs dfs -chown yarn:hadoop #{remote_log_dir} && hdfs dfs -chmod 1777 #{remote_log_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{remote_log_dir}", user: 'hdfs'
  action :nothing
end

am_staging_dir =
  if node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('yarn.app.mapreduce.am.staging-dir')
    node['hadoop']['mapred_site']['yarn.app.mapreduce.am.staging-dir']
  else
    '/tmp/hadoop-yarn/staging'
  end

node.default['hadoop']['mapred_site']['yarn.app.mapreduce.am.staging-dir'] = am_staging_dir

execute 'yarn-app-mapreduce-am-staging-dir' do
  command "hdfs dfs -mkdir -p #{am_staging_dir} && hdfs dfs -chown yarn:hadoop #{am_staging_dir} && hdfs dfs -chmod 1777 #{am_staging_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  action :nothing
end

# Copy MapReduce tarball to HDFS for HDP 2.2+ and IOP
dfs = node['hadoop']['core_site']['fs.defaultFS']
execute 'hdp22-mapreduce-tarball' do
  command <<-EOS
  hdfs dfs -mkdir -p #{dfs}/hdp/apps/#{hdp_version}/mapreduce && \
  hdfs dfs -put #{hadoop_lib_dir}/hadoop/mapreduce.tar.gz /hdp/apps/#{hdp_version}/mapreduce && \
  hdfs dfs -chown -R hdfs:hadoop /hdp && \
  hdfs dfs -chmod -R 555 /hdp/apps/#{hdp_version}/mapreduce && \
  hdfs dfs -chmod -R 444 /hdp/apps/#{hdp_version}/mapreduce/mapreduce.tar.gz
  EOS
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{dfs}/hdp/apps/#{hdp_version}/mapreduce", user: 'hdfs'
  only_if { hdp22? }
  action :nothing
end

iop_version = node['hadoop']['distribution_version']
execute 'iop-mapreduce-tarball' do
  command <<-EOS
  hdfs dfs -mkdir -p #{dfs}/iop/apps/#{iop_version}/mapreduce && \
  hdfs dfs -put #{hadoop_lib_dir}/hadoop/mapreduce.tar.gz /iop/apps/#{iop_version}/mapreduce && \
  hdfs dfs -chown -R hdfs:hadoop /iop && \
  hdfs dfs -chmod -R 555 /iop/apps/#{iop_version}/mapreduce && \
  hdfs dfs -chmod -R 444 /iop/apps/#{iop_version}/mapreduce/mapreduce.tar.gz
  EOS
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{dfs}/iop/apps/#{iop_version}/mapreduce", user: 'hdfs'
  only_if { iop? }
  action :nothing
end

yarn_log_dir =
  if node['hadoop'].key?('yarn_env') && node['hadoop']['yarn_env'].key?('yarn_log_dir')
    node['hadoop']['yarn_env']['yarn_log_dir']
  elsif hdp22? || iop?
    '/var/log/hadoop/yarn'
  else
    '/var/log/hadoop-yarn'
  end

yarn_pid_dir =
  if hdp22? || iop?
    '/var/run/hadoop/yarn'
  else
    '/var/run/hadoop-yarn'
  end

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'yarn_pid_dir' => yarn_pid_dir,
    'yarn_log_dir' => yarn_log_dir,
    'yarn_ident_string' => 'yarn',
    'yarn_conf_dir' => '/etc/hadoop/conf',
  }
end

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'desc' => 'Hadoop YARN ResourceManager',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{hadoop_lib_dir}/hadoop-yarn/sbin/yarn-daemon.sh",
    'args' => '--config ${CONF_DIR} start resourcemanager',
    'confdir' => '${HADOOP_CONF_DIR}',
    'user' => 'yarn',
    'home' => "#{hadoop_lib_dir}/hadoop",
    'pidfile' => '${YARN_PID_DIR}/yarn-yarn-resourcemanager.pid',
    'logfile' => "${YARN_LOG_DIR}/#{pkg}.log",
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action :nothing
end

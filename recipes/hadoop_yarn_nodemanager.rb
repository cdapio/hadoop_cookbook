#
# Cookbook:: hadoop
# Recipe:: hadoop_yarn_nodemanager
#
# Copyright © 2013-2017 Cask Data, Inc.
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
pkg = 'hadoop-yarn-nodemanager'

# Ensure permissions for secure Hadoop... this *should* be no-op
file "#{hadoop_lib_dir}/hadoop-yarn/bin/container-executor" do
  owner 'root'
  group 'yarn'
  mode '6050'
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
nm_local_dirs =
  if node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?('yarn.nodemanager.local-dirs')
    node['hadoop']['yarn_site']['yarn.nodemanager.local-dirs']
  else
    'file:///tmp/hadoop-yarn/nm-local-dir'
  end
nm_log_dirs =
  if node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?('yarn.nodemanager.log-dirs')
    node['hadoop']['yarn_site']['yarn.nodemanager.log-dirs']
  else
    "#{yarn_log_dir}/userlogs"
  end

node.default['hadoop']['yarn_site']['yarn.nodemanager.local-dirs'] = nm_local_dirs
node.default['hadoop']['yarn_site']['yarn.nodemanager.log-dirs'] = nm_log_dirs

%w(yarn.nodemanager.local-dirs yarn.nodemanager.log-dirs).each do |opt|
  node['hadoop']['yarn_site'][opt].split(',').each do |dir|
    directory dir.gsub('file://', '') do
      owner 'yarn'
      group 'yarn'
      mode '0755'
      action :create
      recursive true
    end
  end
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
    'desc' => 'Hadoop YARN NodeManager',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{hadoop_lib_dir}/hadoop-yarn/sbin/yarn-daemon.sh",
    'args' => '--config ${CONF_DIR} start nodemanager',
    'confdir' => '${HADOOP_CONF_DIR}',
    'user' => 'yarn',
    'home' => "#{hadoop_lib_dir}/hadoop",
    'pidfile' => '${YARN_PID_DIR}/yarn-yarn-nodemanager.pid',
    'logfile' => "${YARN_LOG_DIR}/#{pkg}.log",
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action :nothing
end

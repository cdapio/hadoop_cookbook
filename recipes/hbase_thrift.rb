#
# Cookbook:: hadoop
# Recipe:: hbase_thrift
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

include_recipe 'hadoop::hbase'
pkg = 'hbase-thrift'

hbase_log_dir =
  if node['hbase'].key?('hbase_env') && node['hbase']['hbase_env'].key?('hbase_log_dir')
    node['hbase']['hbase_env']['hbase_log_dir']
  else
    '/var/log/hbase'
  end

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'hbase_home' => "#{hadoop_lib_dir}/hbase",
    'hbase_pid_dir' => '/var/run/hbase',
    'hbase_log_dir' => hbase_log_dir,
    'hbase_ident_string' => 'hbase',
    'hbase_conf_dir' => '/etc/hbase/conf',
    'hbase_thrift_mode' => '-nonblocking',
  }
end

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'desc' => 'HBase Thrift Interface',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{hadoop_lib_dir}/hbase/bin/hbase-daemon.sh",
    'args' => '--config ${CONF_DIR} start thrift',
    'confdir' => '${HBASE_CONF_DIR}',
    'user' => 'hbase',
    'home' => "#{hadoop_lib_dir}/hbase",
    'pidfile' => "${HBASE_PID_DIR}/hbase-#{pkg}.pid",
    'logfile' => "${HBASE_LOG_DIR}/#{pkg}.log",
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action :nothing
end

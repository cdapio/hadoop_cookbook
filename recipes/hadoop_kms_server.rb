#
# Cookbook:: hadoop
# Recipe:: hadoop_kms_server
#
# Copyright © 2015-2016 Cask Data, Inc.
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

include_recipe 'hadoop::hadoop_kms'
pkg = 'hadoop-kms-server'

hadoop_kms_log_dir =
  if node['hadoop_kms'].key?('kms_env') && node['hadoop_kms']['kms_env'].key?('kms_log')
    node['hadoop_kms']['kms_env']['kms_log']
  else
    '/var/log/hadoop-kms'
  end

# Create /etc/default/hadoop-kms-server
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'kms_user' => 'kms',
    'kms_config' => '/etc/hadoop-kms/conf',
    'kms_log' => hadoop_kms_log_dir,
    'kms_temp' => '/var/run/hadoop-kms',
    'kms_catalina_home' => '/usr/lib/bigtop-tomcat',
    'catalina_pid' => '/var/run/hadoop-kms/hadoop-kms-kms.pid',
    'catalina_base' => '/var/lib/hadoop-kms/tomcat-deployment',
    'catalina_tmpdir' => '/var/run/hadoop-kms',
  }
end

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'desc' => 'Hadoop Key Management Service Server',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{hadoop_lib_dir}/hadoop-kms/sbin/kms.sh",
    'args' => '--config ${CONF_DIR} start kms',
    'confdir' => '${KMS_CONFIG}',
    'user' => 'kms',
    'home' => "#{hadoop_lib_dir}/hadoop-kms",
    'pidfile' => '${CATALINA_PID}',
    'logfile' => "${KMS_LOG}/#{pkg}.log",
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action :nothing
end

#
# Cookbook Name:: hadoop
# Recipe:: hive_server
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

include_recipe 'hadoop::hive'
include_recipe 'hadoop::_system_tuning'
pkg = 'hive-server'

package pkg do
  action :nothing
end

# Hack to prevent auto-start of services, see COOK-26
ruby_block "package-#{pkg}" do
  block do
    begin
      policy_rcd('disable') if node['platform_family'] == 'debian'
      resources("package[#{pkg}]").run_action(:install)
    ensure
      policy_rcd('enable') if node['platform_family'] == 'debian'
    end
  end
end

hive_log_dir =
  if node['hive'].key?('hive_env') && node['hive']['hive_env'].key?('hive_log_dir')
    node['hive']['hive_env']['hive_log_dir']
  else
    '/var/log/hive'
  end

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables :options => {
    'hive_home' => "#{hadoop_lib_dir}/hive",
    'hive_pid_dir' => '/var/run/hive',
    'hive_log_dir' => hive_log_dir,
    'hive_ident_string' => 'hive'
  }
end

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables :options => {
    'desc' => 'Hive Server',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{hadoop_lib_dir}/hive/bin/hive",
    'args' => '--config /etc/hive/conf --service server',
    'user' => 'hive',
    'home' => "#{hadoop_lib_dir}/hive",
    'pidfile' => "${HIVE_PID_DIR}/#{pkg}.pid",
    'logfile' => "${HIVE_LOG_DIR}/#{pkg}.log"
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

#
# Cookbook:: hadoop
# Recipe:: storm_supervisor
#
# Copyright © 2015 VAHNA
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
require 'yaml'

include_recipe 'hadoop::storm'

pkg = 'storm-supervisor'

storm_conf_dir = "/etc/storm/#{node['storm']['conf_dir']}"

storm_log_dir =
  if node['storm'].key?('storm_env') && node['storm']['storm_env'].key?('storm_log_dir')
    node['storm']['storm_env']['storm_log_dir']
  else
    '/var/log/storm'
  end

storm_home_dir =
  if node['storm'].key?('storm_env') && node['storm']['storm_env'].key?('storm_home')
    node['storm']['storm_env']['storm_home']
  else
    "#{hadoop_lib_dir}/storm"
  end

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'desc' => 'Storm Nimbus Server',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{storm_home_dir}/bin/storm",
    'confdir' => storm_conf_dir,
    'args' => 'supervisor &',
    'user' => 'storm',
    'home' => storm_home_dir,
    'pidfile' => "${STORM_PID_DIR}/#{pkg}.pid",
    'logfile' => "${STORM_LOG_DIR}/#{pkg}.log",
  }
end

# Start storm-env.sh
template "#{storm_conf_dir}/#{pkg}-env.sh" do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: node['storm']['storm_env']
  only_if { node['storm'].key?('storm_env') && !node['storm']['storm_env'].empty? }
end # End storm-env.sh

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'storm_home' => storm_home_dir,
    'storm_pid_dir' => '/var/run/storm',
    'storm_log_dir' => storm_log_dir,
    'storm_conf_dir' => storm_conf_dir,
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action :nothing
end

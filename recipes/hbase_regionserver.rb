#
# Cookbook Name:: hadoop
# Recipe:: hbase_regionserver
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
include_recipe 'hadoop::_hbase_checkconfig'
include_recipe 'hadoop::_system_tuning'
pkg = 'hbase-regionserver'

# Load helpers
Chef::Recipe.send(:include, Hadoop::Helpers)
Chef::Resource::Template.send(:include, Hadoop::Helpers)

package pkg do
  action :nothing
end

# Hack to prevent auto-start of services, see COOK-26
ruby_block "package-#{pkg}" do
  block do
    begin
      Chef::Resource::RubyBlock.send(:include, Hadoop::Helpers)
      policy_rcd('disable') if node['platform_family'] == 'debian'
      resources("package[#{pkg}]").run_action(:install)
    ensure
      policy_rcd('enable') if node['platform_family'] == 'debian'
    end
  end
end

hbase_log_dir =
  if node['hbase'].key?('hbase_env') && node['hbase']['hbase_env'].key?('hbase_log_dir')
    node['hbase']['hbase_env']['hbase_log_dir']
  else
    '/var/log/hbase'
  end

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables :options => {
    'hbase_home' => "#{lib_dir}/hbase",
    'hbase_pid_dir' => '/var/run/hbase',
    'hbase_log_dir' => hbase_log_dir,
    'hbase_ident_string' => 'hbase'
  }
end

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables :options => {
    'desc' => 'HBase RegionServer',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{lib_dir}/hbase/bin/hbase-daemon.sh",
    'args' => '--config /etc/hbase/conf start regionserver',
    'user' => 'hbase',
    'home' => "#{lib_dir}/hbase",
    'pidfile' => "${HBASE_PID_DIR}/#{pkg}.pid",
    'logfile' => "${HBASE_LOG_DIR}/#{pkg}.log"
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

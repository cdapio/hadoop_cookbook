#
# Cookbook Name:: hadoop
# Recipe:: hadoop_yarn_nodemanager
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
pkg = 'hadoop-yarn-nodemanager'

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

%w(yarn.nodemanager.local-dirs yarn.nodemanager.log-dirs).each do |opt|
  next unless node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?(opt)
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

# Ensure permissions for secure Hadoop... this *should* be no-op
container_executor_path =
  if node['hadoop']['distribution'] == 'hdp' && (node['hadoop']['distribution_version'].to_s == '2' || \
                                                 node['hadoop']['distribution_version'].to_f == 2.2)
    '/usr/hdp/current/hadoop-yarn-nodemanager/bin'
  else
    '/usr/lib/hadoop-yarn/bin'
  end

file "#{container_executor_path}/container-executor" do
  owner 'root'
  group 'yarn'
  mode '6050'
end

yarn_log_dir =
  if node['hadoop'].key?('yarn_env') && node['hadoop']['yarn_env'].key?('yarn_log_dir')
    node['hadoop']['yarn_env']['yarn_log_dir']
  elsif hdp22?
    '/var/log/hadoop/yarn'
  else
    '/var/log/hadoop-yarn'
  end

yarn_pid_dir =
  if hdp22?
    '/var/run/hadoop/yarn'
  else
    '/var/run/hadoop-yarn'
  end

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables :options => {
    'yarn_pid_dir' => yarn_pid_dir,
    'yarn_log_dir' => yarn_log_dir,
    'yarn_ident_string' => 'yarn',
    'yarn_conf_dir' => '/etc/hadoop/conf'
  }
end

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables :options => {
    'desc' => 'Hadoop YARN NodeManager',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{hadoop_lib_dir}/hadoop-yarn/sbin/yarn-daemon.sh",
    'args' => '--config /etc/hadoop/conf start nodemanager',
    'user' => 'yarn',
    'home' => "#{hadoop_lib_dir}/hadoop",
    'pidfile' => "${YARN_PID_DIR}/#{pkg}.pid",
    'logfile' => "${YARN_LOG_DIR}/#{pkg}.log"
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

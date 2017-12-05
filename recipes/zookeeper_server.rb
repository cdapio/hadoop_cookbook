#
# Cookbook:: hadoop
# Recipe:: zookeeper_server
#
# Copyright © 2013-2016 Cask Data, Inc.
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

include_recipe 'hadoop::repo'
include_recipe 'hadoop::zookeeper'
pkg = 'zookeeper-server'

# HDP 2.0.11.0 (maybe others) doesn't create zookeeper group
group 'zookeeper' do
  action :create
end

# Ensure zookeeper user has shell access
user 'zookeeper' do
  action :manage
  shell '/bin/bash'
end

zookeeper_conf_dir = "/etc/zookeeper/#{node['zookeeper']['conf_dir']}"

zookeeper_data_dir =
  if node['zookeeper'].key?('zoocfg') && node['zookeeper']['zoocfg'].key?('dataDir')
    node['zookeeper']['zoocfg']['dataDir']
  else
    '/var/lib/zookeeper'
  end

zookeeper_datalog_dir =
  if node['zookeeper'].key?('zoocfg') && node['zookeeper']['zoocfg'].key?('dataLogDir')
    node['zookeeper']['zoocfg']['dataLogDir']
  else
    '/var/lib/zookeeper'
  end

zookeeper_client_port =
  if node['zookeeper'].key?('zoocfg') && node['zookeeper']['zoocfg'].key?('clientPort')
    node['zookeeper']['zoocfg']['clientPort']
  else
    '2181'
  end

node.default['zookeeper']['zoocfg']['dataDir'] = zookeeper_data_dir
node.default['zookeeper']['zoocfg']['dataLogDir'] = zookeeper_datalog_dir
node.default['zookeeper']['zoocfg']['clientPort'] = zookeeper_client_port

directory zookeeper_data_dir do
  owner 'zookeeper'
  group 'zookeeper'
  mode '0755'
  recursive true
  action :create
end

directory "#{zookeeper_data_dir}/version-2" do
  owner 'zookeeper'
  group 'zookeeper'
  mode '0755'
  recursive true
  action :create
end

unless zookeeper_datalog_dir == zookeeper_data_dir
  directory zookeeper_datalog_dir do
    owner 'zookeeper'
    group 'zookeeper'
    mode '0755'
    recursive true
    action :create
    only_if { node['zookeeper']['zoocfg'].key?('dataLogDir') }
  end

  directory "#{zookeeper_datalog_dir}/version-2" do
    owner 'zookeeper'
    group 'zookeeper'
    mode '0755'
    recursive true
    action :create
    only_if { node['zookeeper']['zoocfg'].key?('dataLogDir') }
  end
end

# Setup zoo.cfg
template "#{zookeeper_conf_dir}/zoo.cfg" do
  source 'generic.properties.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  variables properties: node['zookeeper']['zoocfg']
  only_if { node['zookeeper'].key?('zoocfg') && !node['zookeeper']['zoocfg'].empty? }
end # End zoo.cfg

# Try and find the current node in the list of configured servers. If the node was found then write the myid file
myid = nil
1.upto(255) do |index|
  server = node['zookeeper']['zoocfg']["server.#{index}"]
  next if server.nil?
  next unless server.start_with?("#{node['fqdn']}:") || server.start_with?("#{node['ipaddress']}:") || server.start_with?("#{node['hostname']}:")
  myid = index
  break
end

template "#{zookeeper_data_dir}/myid" do
  source 'zookeeper-myid.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  variables myid: myid
  not_if { myid.nil? }
end # End zoo.cfg

zookeeper_log_dir =
  if node['zookeeper'].key?('zookeeper_env') && node['zookeeper']['zookeeper_env'].key?('zookeeper_log_dir')
    node['zookeeper']['zookeeper_env']['zookeeper_log_dir']
  else
    '/var/log/zookeeper'
  end

directory zookeeper_log_dir do
  owner 'zookeeper'
  group 'zookeeper'
  mode '0755'
  action :create
  recursive true
  only_if { node['zookeeper'].key?('zookeeper_env') && node['zookeeper']['zookeeper_env'].key?('zookeeper_log_dir') }
end

unless zookeeper_log_dir == '/var/log/zookeeper'
  # Delete default directory, if we aren't set to it
  directory '/var/log/zookeeper' do
    action :delete
    recursive true
    not_if 'test -L /var/log/zookeeper'
  end
  # symlink
  link '/var/log/zookeeper' do
    to zookeeper_log_dir
  end
end

# Setup zookeeper-env.sh
template "#{zookeeper_conf_dir}/zookeeper-env.sh" do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: node['zookeeper']['zookeeper_env']
  only_if { node['zookeeper'].key?('zookeeper_env') && !node['zookeeper']['zookeeper_env'].empty? }
end # End zookeeper-env.sh

# Setup log4j.properties
template "#{zookeeper_conf_dir}/log4j.properties" do
  source 'generic.properties.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables properties: node['zookeeper']['log4j']
  only_if { node['zookeeper'].key?('log4j') && !node['zookeeper']['log4j'].empty? }
end # End log4j.properties

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'zookeeper_home' => "#{hadoop_lib_dir}/zookeeper",
    'zookeeper_pid_dir' => '/var/run/zookeeper',
    'zoopidfile' => "${ZOOKEEPER_PID_DIR}/#{pkg}.pid",
    'zookeeper_log_dir' => zookeeper_log_dir,
    'zookeeper_conf_dir' => zookeeper_conf_dir,
    'zoo_log_dir' => zookeeper_log_dir,
    'zoocfgdir' => zookeeper_conf_dir,
  }
end

binary = hdp22? || iop? ? "#{hadoop_lib_dir}/zookeeper/bin/#{pkg}" : "/usr/bin/#{pkg}"

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'desc' => 'ZooKeeper Server',
    'name' => pkg,
    'process' => 'java',
    'binary' => binary,
    'args' => 'start',
    'confdir' => '${ZOOKEEPER_CONF_DIR}',
    'user' => 'zookeeper',
    'home' => "#{hadoop_lib_dir}/zookeeper",
    'pidfile' => "${ZOOKEEPER_PID_DIR}/#{pkg}.pid",
    'logfile' => "${ZOOKEEPER_LOG_DIR}/#{pkg}.log",
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action :nothing
end

# Another Hortonworks mess to clean up, their packages force-install blank configs here
directory '/etc/zookeeper/conf' do
  action :delete
  recursive true
  not_if 'test -L /etc/zookeeper/conf'
end

# Update alternatives to point to our configuration
execute 'update zookeeper-conf alternatives' do
  command "update-alternatives --install /etc/zookeeper/conf zookeeper-conf /etc/zookeeper/#{node['zookeeper']['conf_dir']} 50"
  not_if "update-alternatives --display zookeeper-conf | grep best | awk '{print $5}' | grep /etc/zookeeper/#{node['zookeeper']['conf_dir']}"
end

#
# Cookbook Name:: hadoop
# Recipe:: storm
#
# Copyright © 2015 VAHNA
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

include_recipe 'hadoop::repo'
include_recipe 'hadoop::_storm_checkconfig'

package hadoop_package('storm') do
  action :install
  only_if { hdp22? && node['storm']['release']['install'] == false }
  node.override['storm']['storm_env']['storm_home'] = "#{hadoop_lib_dir}/storm"
end

unless node['storm']['release']['install'] == false
  remote_file "#{node['storm']['release']['install_path']}/apache-storm-#{node['storm']['release']['version']}.tar.gz" do
    source "http://www.us.apache.org/dist/storm/apache-storm-#{node['storm']['release']['version']}/apache-storm-#{node['storm']['release']['version']}.tar.gz"
    checksum node['storm']['release']['checksum']
    not_if { ::File.exist?("#{node['storm']['release']['install_path']}/apache-storm-#{node['storm']['release']['version']}.tar.gz") }
    action :create_if_missing
  end

  execute 'install-storm-release' do
    cwd node['storm']['release']['install_path']
    user 'root'
    group 'root'
    command "tar -xvzf apache-storm-#{node['storm']['release']['version']}.tar.gz"
    not_if "test -d #{node['storm']['release']['install_path']}/apache-storm-#{node['storm']['release']['version']}"
    action :run
  end

  link "#{node['storm']['release']['install_path']}/storm" do
    to "#{node['storm']['release']['install_path']}/apache-storm-#{node['storm']['release']['version']}"
    action :create
  end

  group 'storm' do
    action :create
  end

  user 'storm' do
    comment 'Storm service account'
    gid 'storm'
    action :create
  end

  # override STORM_HOME to use release install
  node.override['storm']['storm_env']['storm_home'] = "#{node['storm']['release']['install_path']}/storm"
end

# Another Hortonworks mess to clean up, their packages force-install blank configs here
directory '/etc/storm/conf' do
  action :delete
  recursive true
  not_if 'test -L /etc/storm/conf'
end

storm_conf_dir = "/etc/storm/#{node['storm']['conf_dir']}"

directory storm_conf_dir do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
  node.override['storm']['storm_env']['storm_conf_dir'] = storm_conf_dir
end

unless storm_conf_dir == "#{node['storm']['storm_env']['storm_home']}/conf"
  # Delete default directory, if we aren't set to it
  directory "#{node['storm']['storm_env']['storm_home']}/conf" do
    action :delete
    recursive true
    not_if "test -L #{node['storm']['storm_env']['storm_home']}/conf"
  end
  # symlink
  link "#{node['storm']['storm_env']['storm_home']}/conf" do
    to storm_conf_dir
  end
end

template "#{storm_conf_dir}/storm.yaml" do
  source 'storm.yaml.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables :storm_conf => node['storm']['storm_conf']
  action :create_if_missing
end

storm_local_dir =
  if node['storm'].key?('storm_conf') && node['storm']['storm_conf'].key?('storm.local.dir')
    node['storm']['storm_conf']['storm.local.dir']
  else
    '/var/lib/storm'
  end

directory storm_local_dir do
  owner 'storm'
  group 'storm'
  mode '0700'
  recursive true
  action :create
  only_if { node['storm'].key?('storm_conf') && node['storm']['storm_conf'].key?('storm.local.dir') }
end

storm_log_dir =
  if node['storm'].key?('storm_conf') && node['storm']['storm_conf'].key?('storm.log.dir')
    node['storm']['storm_conf']['storm.log.dir']
  else
    '/var/log/storm'
  end

directory storm_log_dir do
  owner 'storm'
  group 'storm'
  mode '0755'
  recursive true
  action :create
  # only_if { node['storm'].key?('storm_conf') && node['storm']['storm_conf'].key?('storm.log.dir') }
end

unless storm_log_dir == "#{node['storm']['storm_env']['storm_home']}/logs"
  # Delete default directory, if we aren't set to it
  directory "#{node['storm']['storm_env']['storm_home']}/logs" do
    action :delete
    recursive true
    not_if "test -L #{node['storm']['storm_env']['storm_home']}/logs"
  end
  # symlink
  link "#{node['storm']['storm_env']['storm_home']}/logs" do
    to storm_log_dir
  end
end

# Start storm_env.ini
template "#{storm_conf_dir}/storm_env.ini" do
  source 'storm_env.ini.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables :options => node['storm']['storm_env']
  only_if { node['storm'].key?('storm_env') && !node['storm']['storm_env'].empty? }
end # End storm_env.ini

# Setup jaas.conf
my_vars = {}
if node['storm'].key?('jaas')
  my_vars[:client] = node['storm']['jaas']['client']
  my_vars[:server] = node['storm']['jaas']['server']
end
template "#{storm_conf_dir}/jaas.conf" do
  source 'jaas.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables my_vars
  only_if do
    node['storm'].key?('jaas') && (!node['storm']['jaas']['client'].empty? || !node['storm']['jaas']['server'].empty)
  end
end # End jaas.conf

# Update alternatives to point to our configuration
execute 'update storm-conf alternatives' do
  command "update-alternatives --install /etc/storm/conf storm-conf /etc/storm/#{node['storm']['conf_dir']} 50"
  not_if "update-alternatives --display storm-conf | grep best | awk '{print $5}' | grep /etc/storm/#{node['storm']['conf_dir']}"
end

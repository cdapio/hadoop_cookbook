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
include_recipe 'hadoop::_hive_checkconfig'
include_recipe 'hadoop::_system_tuning'
include_recipe 'hadoop::zookeeper'
pkg = 'hive-server2'

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
  # Hortonworks ships this as part of the hive package
  not_if { node['hadoop']['distribution'] == 'hdp' }
end

template "/etc/init.d/#{pkg}" do
  source "#{pkg}.erb"
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  only_if { node['hadoop']['distribution'] == 'hdp' }
end

hive_conf_dir = "/etc/hive/#{node['hive']['conf_dir']}"

# Setup jaas.conf
if node['hive'].key?('jaas')
  my_vars = {
    # Only use client, for connecting to secure ZooKeeper
    :client => node['hive']['jaas']['client']
  }

  template "#{hive_conf_dir}/jaas.conf" do
    source 'jaas.conf.erb'
    mode '0644'
    owner 'hive'
    group 'hive'
    action :create
    variables my_vars
  end
end # End jaas.conf

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

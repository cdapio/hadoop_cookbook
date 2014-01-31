#
# Cookbook Name:: hadoop
# Recipe:: zookeeper_server
#
# Copyright (C) 2013 Continuuity, Inc.
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

package "zookeeper-server" do
  action :install
end

zookeeper_conf_dir = "/etc/zookeeper/#{node['zookeeper']['conf_dir']}"

directory zookeeper_conf_dir do
  mode "0755"
  owner "root"
  group "root"
  action :create
  recursive true
end

# Setup zoo.cfg
if node['zookeeper'].has_key? 'zoocfg'

  # We need to create a data directory, if it exists
  zookeeper_data_dir =
    if node['zookeeper']['zoocfg'].has_key? 'dataDir'
      node['zookeeper']['zoocfg']['dataDir']
    else
      "/var/lib/zookeeper"
    end
  zookeeper_client_port =
    if node['zookeeper']['zoocfg'].has_key? 'clientPort'
      node['zookeeper']['zoocfg']['clientPort']
    else
      '2181'
    end

  node.default['zookeeper']['zoocfg']['dataDir'] = zookeeper_data_dir
  node.default['zookeeper']['zoocfg']['clientPort'] = zookeeper_client_port
  myVars = { :properties => node['zookeeper']['zoocfg'] }

  directory node['zookeeper']['zoocfg']['dataDir'] do
    owner "zookeeper"
    group "zookeeper"
    mode "0755"
    recursive true
    action :create
  end

  directory node['zookeeper']['zoocfg']['dataLogDir'] do
    owner "zookeeper"
    group "zookeeper"
    mode "0755"
    recursive true
    action :create
    only_if { node['zookeeper']['zoocfg'].has_key? 'dataLogDir' }
  end

  template "#{zookeeper_conf_dir}/zoo.cfg" do
    owner "root"
    group "root"
    mode "0644"
    variables myVars
    source "generic.properties.erb"
    action :create
  end
end # End zoo.cfg

# Setup log4j.properties
if node['hbase'].has_key? 'log4j'
  myVars = { :properties => node['zookeeper']['log4j'] }

  template "#{zookeeper_conf_dir}/log4j.properties" do
    source "generic.properties.erb"
    mode "0644"
    owner "root"
    group "root"
    action :create
    variables myVars
  end
end # End log4j.properties

service "zookeeper-server" do
  action :nothing
end

# Update alternatives to point to our configuration
execute "update zookeeper-conf alternatives" do
  command "update-alternatives --install /etc/zookeeper/conf zookeeper-conf /etc/zookeeper/#{node['zookeeper']['conf_dir']} 50"
  not_if "update-alternatives --display zookeeper-conf | grep best | awk '{print $5}' | grep /etc/zookeeper/#{node['zookeeper']['conf_dir']}"
end

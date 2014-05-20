#
# Cookbook Name:: hadoop
# Recipe:: hive_server
#
# Copyright (C) 2013-2014 Continuuity, Inc.
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
include_recipe 'hadoop::zookeeper'
include_recipe 'hadoop::hive_checkconfig'

package 'hive-server2' do
  action :install
  # Hortonworks ships this as part of the hive package
  not_if { node['hadoop']['distribution'] == 'hdp' }
end

template '/etc/init.d/hive-server2' do
  source 'hive-server2.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  only_if { node['hadoop']['distribution'] == 'hdp' }
end

service 'hive-server2' do
  status_command 'service hive-server2 status'
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

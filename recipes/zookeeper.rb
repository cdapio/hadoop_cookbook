#
# Cookbook Name:: hadoop
# Recipe:: zookeeper
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

include_recipe 'hadoop::repo'

# HDP 2.0 zookeeper package doesn't create zookeeper group, creates hadoop, instead
group 'zookeeper' do
  action :create
end

package 'zookeeper' do
  action :install
end

zookeeper_conf_dir = "/etc/zookeeper/#{node['zookeeper']['conf_dir']}"

directory zookeeper_conf_dir do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
end

# Setup jaas.conf
if node['zookeeper'].key?('jaas')
  my_vars = { :options => node['zookeeper']['jaas'] }

  template "#{zookeeper_conf_dir}/jaas.conf" do
    source 'jaas.conf.erb'
    mode '0755'
    owner 'zookeeper'
    group 'zookeeper'
    action :create
    variables({
      :client => node['zookeeper']['jaas']['client'],
      :server => node['zookeeper']['jaas']['server']
    })
  end
end # End jaas.conf

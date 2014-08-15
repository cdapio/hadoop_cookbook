#
# Cookbook Name:: hadoop
# Recipe:: hadoop_yarn_proxyserver
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

include_recipe 'hadoop::default'

if node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?('yarn.web-proxy.address')
  Chef::Log.info("Setting up YARN Web Proxy at #{node['hadoop']['yarn_site']['yarn.web-proxy.address']}")
else
  Chef::Application.fatal!("YARN Web Proxy must be configured! Set default['hadoop']['yarn_site']['yarn.web-proxy.address']}!")
end

package 'hadoop-yarn-proxyserver' do
  action :install
end

service 'hadoop-yarn-proxyserver' do
  status_command 'service hadoop-yarn-proxyserver status'
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

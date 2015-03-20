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
file '/usr/lib/hadoop-yarn/bin/container-executor' do
  owner 'root'
  group 'yarn'
  mode '6050'
end

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

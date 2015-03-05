#
# Cookbook Name:: hadoop
# Recipe:: _zookeeper_checkconfig
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

# If using JAAS, make sure it's configured fully
if node['zookeeper'].key?('jaas')
  %w(client server).each do |key|
    next unless node['zookeeper']['jaas'].key?(key) && node['zookeeper']['jaas'][key].key?('usekeytab') &&
                node['zookeeper']['jaas'][key]['usekeytab'].to_s == 'true'

    next unless node['zookeeper']['jaas'][key]['keytab'].nil? || node['zookeeper']['jaas'][key]['principal'].nil?
    Chef::Application.fatal!("You must set node['zookeeper']['jaas']['#{key}']['keytab'] and node['zookeeper']['jaas']['#{key}']['principal'] with node['zookeeper']['jaas'][key]['usekeytab']")
  end
end

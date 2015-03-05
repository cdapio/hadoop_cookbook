#
# Cookbook Name:: hadoop
# Recipe:: _hive_checkconfig
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

# HiveServer2 requires Hive Table Lock Manager
# http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH4/4.2.0/CDH4-Installation-Guide/cdh4ig_topic_18_5.html
if node['hive'].key?('hive_site') && node['hive']['hive_site'].key?('hive.support.concurrency') &&
   node['hive']['hive_site']['hive.support.concurrency'].to_s == 'true' && node['hive']['hive_site'].key?('hive.zookeeper.quorum')
  Chef::Log.info('Hive Table Lock Manager enabled')
  Chef::Log.info("Hive ZooKeeper Quorum: #{node['hive']['hive_site']['hive.zookeeper.quorum']}")
else
  Chef::Application.fatal!("You *must* set node['hive']['hive_site']['hive.support.concurrency'] and node['hive']['hive_site']['hive.zookeeper.quorum']")
end

# If using JAAS, make sure it's configured fully
if node['hive'].key?('jaas')
  %w(client server).each do |key|
    next unless node['hive']['jaas'].key?(key) && node['hive']['jaas'][key].key?('usekeytab') &&
                node['hive']['jaas'][key]['usekeytab'].to_s == 'true'

    next unless node['hive']['jaas'][key]['keytab'].nil? || node['hive']['jaas'][key]['principal'].nil?
    Chef::Application.fatal!("You must set node['hive']['jaas']['#{key}']['keytab'] and node['hive']['jaas']['#{key}']['principal'] with node['hive']['jaas'][key]['usekeytab']")
  end
end

#
# Cookbook Name:: hadoop
# Recipe:: hadoop_mapreduce_tasktracker
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

include_recipe 'hadoop::default'
include_recipe 'hadoop::_system_tuning'
pkg = 'hadoop-0.20-mapreduce-tasktracker'

mapred_local_dirs =
  hadoop_config('hadoop', 'mapred_site', 'mapreduce.cluster.local.dir', 'mapred.local.dir', 'file:///tmp/hadoop-mapred/local')

node.default['hadoop']['mapred_site']['mapreduce.cluster.local.dir'] = mapred_local_dirs

mapred_local_dirs.split(',').each do |dir|
  directory dir.gsub('file://', '') do
    mode '0755'
    owner 'mapred'
    group 'mapred'
    action :create
    recursive true
  end
end

dpkg_autostart pkg do
  allow false
  only_if { node['hadoop']['distribution'] == 'cdh' }
end

package pkg do
  action :install
  only_if { node['hadoop']['distribution'] == 'cdh' }
end

service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action :nothing
  only_if { node['hadoop']['distribution'] == 'cdh' }
end

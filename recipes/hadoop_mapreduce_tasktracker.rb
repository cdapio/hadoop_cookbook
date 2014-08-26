#
# Cookbook Name:: hadoop
# Recipe:: hadoop_mapreduce_tasktracker
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

mapred_local_dirs =
  if node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('mapreduce.cluster.local.dir')
    node['hadoop']['mapred_site']['mapreduce.cluster.local.dir']
  elsif node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('mapred.local.dir')
    node['hadoop']['mapred_site']['mapred.local.dir']
  else
    'file:///tmp/hadoop-mapred/local'
  end

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

# Only CDH supports a TaskTracker package
package 'hadoop-0.20-mapreduce-tasktracker' do
  action :install
  only_if { node['hadoop']['distribution'] == 'cdh' }
end

service 'hadoop-0.20-mapreduce-tasktracker' do
  status_command 'service hadoop-0.20-mapreduce-tasktracker status'
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
  only_if { node['hadoop']['distribution'] == 'cdh' }
end

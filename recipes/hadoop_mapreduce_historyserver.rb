#
# Cookbook Name:: hadoop
# Recipe:: hadoop_mapreduce_historyserver
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

package 'hadoop-mapreduce-historyserver' do
  action :install
end

service 'hadoop-mapreduce-historyserver' do
  status_command 'service hadoop-mapreduce-historyserver status'
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

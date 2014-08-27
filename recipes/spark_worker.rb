#
# Cookbook Name:: hadoop
# Recipe:: spark_worker
#
# Copyright (C) 2014 Continuuity, Inc.
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
include_recipe 'hadoop::spark'

package 'spark-worker' do
  action :install
end

if node['spark'].key?('spark_env') && node['spark']['spark_env'].key?('spark_worker_dir')
  directory node['spark']['spark_env']['spark_worker_dir'] do
    mode '0755'
    owner 'spark'
    group 'spark'
    action :create
    recursive true
    only_if { node['spark']['spark_env'].key?('spark_worker_dir') }
  end
end

service 'spark-worker' do
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

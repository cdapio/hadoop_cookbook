#
# Cookbook Name:: hadoop
# Recipe:: hbase_master
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

include_recipe 'hadoop::hbase'
include_recipe 'hadoop::hbase_checkconfig'

package 'hbase-master' do
  action :install
end

# HBase can use a local directory or an HDFS directory for its rootdir...
# if HDFS, create execute block with action :nothing
# else create the local directory when file://
if node['hbase']['hbase_site']['hbase.rootdir'] =~ %r{^hdfs://} || (node['hbase']['hbase_site']['hbase.rootdir'] =~ /^\// && node['hbase']['hbase_site']['hbase.cluster.distributed'].to_s == 'true')
  execute 'hbase-hdfs-rootdir' do
    command "hdfs dfs -mkdir -p #{node['hbase']['hbase_site']['hbase.rootdir']} && hdfs dfs -chown hbase #{node['hbase']['hbase_site']['hbase.rootdir']}"
    timeout 300
    user 'hdfs'
    group 'hdfs'
    not_if "hdfs dfs -test -d #{node['hbase']['hbase_site']['hbase.rootdir']}", :user => 'hdfs'
    action :nothing
  end
elsif node['hbase']['hbase_site']['hbase.rootdir'] =~ %r{^/|^file://}
  directory node['hbase']['hbase_site']['hbase.rootdir'].gsub('file://', '') do
    owner 'hbase'
    group 'hbase'
    mode '0700'
    action :create
    recursive true
  end
else
  Chef::Application.fatal!("node['hbase']['hbase_site']['hbase.rootdir'] must be set to file:// or hdfs:// locations")
end

# https://hbase.apache.org/book/hbase.secure.bulkload.html
bulkload_dir =
  if node['hbase']['hbase_site'].key? 'hbase.bulkload.staging.dir'
    node['hbase']['hbase_site']['hbase.bulkload.staging.dir']
  else
    '/tmp/hbase-staging'
  end

node.default['hbase']['hbase_site']['hbase.bulkload.staging.dir'] = bulkload_dir

execute 'hbase-bulkload-stagingdir' do
  command "hdfs dfs -mkdir -p #{bulkload_dir} && hdfs dfs -chown hbase:hbase #{bulkload_dir} && hdfs dfs -chmod 711 #{bulkload_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{bulkload_dir}", :user => 'hdfs'
  action :nothing
end

service 'hbase-master' do
  status_command 'service hbase-master status'
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

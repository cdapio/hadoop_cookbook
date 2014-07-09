#
# Cookbook Name:: hadoop
# Recipe:: hadoop_hdfs_journalnode
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

# http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/HDFSHighAvailabilityWithQJM.html

include_recipe 'hadoop::default'
include_recipe 'hadoop::hadoop_hdfs_checkconfig'

package 'hadoop-hdfs-journalnode' do
  action :install
end

dfs_jn_edits_dirs =
  if node['hadoop']['hdfs_site'].key? 'dfs.journalnode.edits.dir'
    node['hadoop']['hdfs_site']['dfs.journalnode.edits.dir']
  else
    Chef::Application.fatal!("JournalNode requires node['hadoop']['hdfs_site']['dfs.journalnode.edits.dir'] to be set")
  end

dfs_jn_edits_dirs.split(',').each do |dir|
  directory dir.gsub('file://', '') do
    mode '0755'
    owner 'hdfs'
    group 'hdfs'
    action :create
    recursive true
  end
end

service 'hadoop-hdfs-journalnode' do
  status_command 'service hadoop-hdfs-journalnode status'
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

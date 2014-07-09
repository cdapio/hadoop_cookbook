#
# Cookbook Name:: hadoop
# Recipe:: hadoop_hdfs_secondarynamenode
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
include_recipe 'hadoop::hadoop_hdfs_checkconfig'

package 'hadoop-hdfs-secondarynamenode' do
  action :install
end

fs_checkpoint_dirs =
  if node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.namenode.checkpoint.dir')
    node['hadoop']['hdfs_site']['dfs.namenode.checkpoint.dir']
  elsif node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('fs.checkpoint.dir')
    node['hadoop']['hdfs_site']['fs.checkpoint.dir']
  else
    'file:///tmp/hadoop-hdfs/dfs/namesecondary'
  end

fs_checkpoint_edits_dirs =
  if node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.namenode.checkpoint.edits.dir')
    node['hadoop']['hdfs_site']['dfs.namenode.checkpoint.edits.dir']
  elsif node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('fs.checkpoint.edits.dir')
    node['hadoop']['hdfs_site']['fs.checkpoint.edits.dir']
  else
    fs_checkpoint_dirs
  end

node.default['hadoop']['hdfs_site']['dfs.namenode.checkpoint.dir'] = fs_checkpoint_dirs
node.default['hadoop']['hdfs_site']['dfs.namenode.checkpoint.edits.dir'] = fs_checkpoint_edits_dirs

snn_dirs =
  if fs_checkpoint_dirs == fs_checkpoint_edits_dirs
    [fs_checkpoint_dirs]
  else
    [fs_checkpoint_dirs, fs_checkpoint_edits_dirs]
  end

snn_dirs.each do |dirs|
  dirs.split(',').each do |dir|
    directory dir.gsub('file://', '') do
      mode '0700'
      owner 'hdfs'
      group 'hdfs'
      action :create
      recursive true
    end
  end
end

service 'hadoop-hdfs-secondarynamenode' do
  status_command 'service hadoop-hdfs-secondarynamenode status'
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

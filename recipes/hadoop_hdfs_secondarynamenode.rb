#
# Cookbook Name:: hadoop
# Recipe:: hadoop_hdfs_secondarynamenode
#
# Copyright (C) 2013 Continuuity, Inc.
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

package "hadoop-hdfs-secondarynamenode" do
  action :install
end

fs_checkpoint_dirs =
  if (node['hadoop'].has_key? 'hdfs_site' and node['hadoop']['hdfs_site'].has_key? 'fs.checkpoint.dir')
    node['hadoop']['hdfs_site']['fs.checkpoint.dir']
  else
    "/tmp/hadoop-hdfs/dfs/namesecondary"
  end

fs_checkpoint_edits_dirs =
  if (node['hadoop'].has_key? 'hdfs_site' and node['hadoop']['hdfs_site'].has_key? 'fs.checkpoint.edits.dir')
    node['hadoop']['hdfs_site']['fs.checkpoint.edits.dir']
  else
    fs_checkpoint_dirs
  end

%w[ fs_checkpoint_dirs fs_checkpoint_edits_dirs ].each do |dirs|
  dirs.split(',').each do |dir|
    directory dir do
      mode 0755
      owner "hdfs"
      group "hdfs"
      action :create
      recursive true
    end
  end
end

service "hadoop-hdfs-secondarynamenode" do
  supports [ :restart => true, :reload => false, :status => true ]
  action :nothing
end

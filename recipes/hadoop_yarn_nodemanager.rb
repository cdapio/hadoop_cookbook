#
# Cookbook Name:: hadoop
# Recipe:: hadoop_yarn_nodemanager
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

package 'hadoop-yarn-nodemanager' do
  action :install
end

# TODO: check for these and set them up
# mapreduce.cluster.local.dir = #{hadoop_tmp_dir}/mapred/local
# mapreduce.jobtracker.system.dir = #{hadoop_tmp_dir}/mapred/system
# mapreduce.jobtracker.staging.root.dir = #{hadoop_tmp_dir}/mapred/staging
# mapreduce.cluster.temp.dir = #{hadoop_tmp_dir}/mapred/temp

# yarn.app.mapreduce.am.staging-dir = /tmp/hadoop-yarn/staging

%w(yarn.nodemanager.local-dirs yarn.nodemanager.log-dirs).each do |opt|
  next unless node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?(opt)
  node['hadoop']['yarn_site'][opt].split(',').each do |dir|
    directory dir.gsub('file://', '') do
      owner 'yarn'
      group 'yarn'
      mode '0755'
      action :create
      recursive true
    end
  end
end

service 'hadoop-yarn-nodemanager' do
  status_command 'service hadoop-yarn-nodemanager status'
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

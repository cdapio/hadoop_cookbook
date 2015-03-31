#
# Cookbook Name:: hadoop
# Recipe:: hadoop_mapreduce_historyserver
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

include_recipe 'hadoop::default'
pkg = 'hadoop-mapreduce-historyserver'

package pkg do
  action :nothing
end

# Hack to prevent auto-start of services, see COOK-26
ruby_block "package-#{pkg}" do
  block do
    begin
      Chef::Resource::RubyBlock.send(:include, Hadoop::Helpers)
      policy_rcd('disable') if node['platform_family'] == 'debian'
      resources("package[#{pkg}]").run_action(:install)
    ensure
      policy_rcd('enable') if node['platform_family'] == 'debian'
    end
  end
end

am_staging_dir =
  if node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('yarn.app.mapreduce.am.staging-dir')
    node['hadoop']['mapred_site']['yarn.app.mapreduce.am.staging-dir']
  else
    '/tmp/hadoop-yarn/staging'
  end

jhs_intermediate_done_dir =
  if node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('mapreduce.jobhistory.intermediate-done-dir')
    node['hadoop']['mapred_site']['mapreduce.jobhistory.intermediate-done-dir']
  else
    "#{am_staging_dir}/history/done_intermediate"
  end

jhs_done_dir =
  if node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('mapreduce.jobhistory.done-dir')
    node['hadoop']['mapred_site']['mapreduce.jobhistory.done-dir']
  else
    "#{am_staging_dir}/history/done"
  end

execute 'mapreduce-jobhistory-intermediate-done-dir' do
  command "hdfs dfs -mkdir -p #{jhs_intermediate_done_dir} && hdfs dfs -chown mapred:hadoop #{jhs_intermediate_done_dir} && hdfs dfs -chmod 1777 #{jhs_intermediate_done_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{jhs_intermediate_done_dir}", :user => 'hdfs'
  action :nothing
end

execute 'mapreduce-jobhistory-done-dir' do
  command "hdfs dfs -mkdir -p #{jhs_done_dir} && hdfs dfs -chown mapred:hadoop #{jhs_done_dir} && hdfs dfs -chmod 1777 #{jhs_done_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{jhs_done_dir}", :user => 'hdfs'
  action :nothing
end

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

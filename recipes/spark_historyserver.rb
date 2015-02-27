#
# Cookbook Name:: hadoop
# Recipe:: spark_historyserver
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

include_recipe 'hadoop::spark'
pkg = 'spark-history-server'

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
  only_if { node['hadoop']['distribution'] == 'cdh' }
end

dfs = node['hadoop']['core_site']['fs.defaultFS']

execute 'hdfs-spark-userdir' do
  command "hdfs dfs -mkdir -p #{dfs}/user/spark && hdfs dfs -chown -R spark:spark #{dfs}/user/spark"
  user 'hdfs'
  group 'hdfs'
  timeout 300
  action :nothing
end

eventlog_dir =
  if node['spark']['spark_defaults'].key?('spark.eventLog.dir')
    node['spark']['spark_defaults']['spark.eventLog.dir']
  else
    '/user/spark/applicationHistory'
  end

execute 'hdfs-spark-eventlog-dir' do
  command "hdfs dfs -mkdir -p #{dfs}#{eventlog_dir} && hdfs dfs -chown -R spark:spark #{dfs}#{eventlog_dir} && hdfs dfs -chmod 1777 #{dfs}#{eventlog_dir}"
  user 'hdfs'
  group 'hdfs'
  timeout 300
  action :nothing
end

if node['hadoop']['distribution'] == 'cdh'
  s_cmd = "service #{pkg}"
else
  s_cmd = 'true #' # Ends with # to make arguments a comment, versus part of command line
end

service 'spark-history-server' do
  status_command "#{s_cmd} status"
  start_command "#{s_cmd} start"
  stop_command "#{s_cmd} stop"
  restart_command "#{s_cmd} restart"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

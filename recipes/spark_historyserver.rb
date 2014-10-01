#
# Cookbook Name:: hadoop
# Recipe:: spark_historyserver
#
# Copyright © 2013-2014 Cask Data, Inc.
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

package 'spark-history-server' do
  action :install
end

dfs = node['hadoop']['core_site']['fs.defaultFS']

execute 'hdfs-spark-userdir' do
  command <<-EOS
    hdfs dfs -mkdir -p #{dfs}/user/spark
    hdfs dfs -chown -R spark:spark #{dfs}/user/spark
  EOS
  user 'hdfs'
  group 'hdfs'
  timeout 300
  action :run
end

if node['spark']['spark_defaults'].key?('spark.eventLog.dir')
  execute 'hdfs-spark-eventlog-dir' do
    command <<-EOS
      hdfs dfs -mkdir -p #{dfs}#{node['spark']['spark_defaults']['spark.eventLog.dir']}
      hdfs dfs -chown -R spark:spark #{dfs}#{node['spark']['spark_defaults']['spark.eventLog.dir']}
      hdfs dfs -chmod 1777 #{dfs}#{node['spark']['spark_defaults']['spark.eventLog.dir']}
    EOS
    user 'hdfs'
    group 'hdfs'
    timeout 300
    action :run
  end
end

service 'spark-history-server' do
  status_command 'service spark-history-server status'
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

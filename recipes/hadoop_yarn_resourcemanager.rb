#
# Cookbook Name:: hadoop
# Recipe:: hadoop_yarn_resourcemanager
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
include_recipe 'hadoop::_system_tuning'
pkg = 'hadoop-yarn-resourcemanager'

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

# TODO: check for these and set them up
# mapreduce.cluster.local.dir = #{hadoop_tmp_dir}/mapred/local
# mapreduce.jobtracker.system.dir = #{hadoop_tmp_dir}/mapred/system
# mapreduce.jobtracker.staging.root.dir = #{hadoop_tmp_dir}/mapred/staging
# mapreduce.cluster.temp.dir = #{hadoop_tmp_dir}/mapred/temp

# We need a /tmp in HDFS
dfs = node['hadoop']['core_site']['fs.defaultFS']
execute 'hdfs-tmpdir' do
  command "hdfs dfs -mkdir -p #{dfs}/tmp && hdfs dfs -chmod 1777 #{dfs}/tmp"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  action :nothing
end

remote_log_dir =
  if node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?('yarn.nodemanager.remote-app-log-dir')
    node['hadoop']['yarn_site']['yarn.nodemanager.remote-app-log-dir']
  else
    '/tmp/logs'
  end

node.default['hadoop']['yarn_site']['yarn.nodemanager.remote-app-log-dir'] = remote_log_dir

execute 'yarn-remote-app-log-dir' do
  command "hdfs dfs -mkdir -p #{remote_log_dir} && hdfs dfs -chown yarn:hadoop #{remote_log_dir} && hdfs dfs -chmod 1777 #{remote_log_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{remote_log_dir}", :user => 'hdfs'
  action :nothing
end

am_staging_dir =
  if node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('yarn.app.mapreduce.am.staging-dir')
    node['hadoop']['mapred_site']['yarn.app.mapreduce.am.staging-dir']
  else
    '/tmp/hadoop-yarn/staging'
  end

node.default['hadoop']['mapred_site']['yarn.app.mapreduce.am.staging-dir'] = am_staging_dir

execute 'yarn-app-mapreduce-am-staging-dir' do
  command "hdfs dfs -mkdir -p #{am_staging_dir} && hdfs dfs -chown yarn:hadoop #{am_staging_dir} && hdfs dfs -chmod 1777 #{am_staging_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -ls #{::File.dirname(am_staging_dir)} | grep #{am_staging_dir} | awk '{print $1,$3,$4}' | grep 'drwxrwxrwt yarn hadoop'", :user => 'hdfs'
  action :nothing
end

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

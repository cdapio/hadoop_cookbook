#
# Cookbook Name:: hadoop
# Recipe:: hadoop_mapreduce_jobtracker
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
pkg = 'hadoop-0.20-mapreduce-jobtracker'

# TODO: check for these and set them up
# mapreduce.jobtracker.system.dir = #{hadoop_tmp_dir}/mapred/system (inside HDFS) = mapred.system.dir
# mapreduce.jobtracker.staging.root.dir = #{hadoop_tmp_dir}/mapred/staging
# mapreduce.cluster.temp.dir = #{hadoop_tmp_dir}/mapred/temp

mapred_local_dirs =
  if node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('mapreduce.cluster.local.dir')
    node['hadoop']['mapred_site']['mapreduce.cluster.local.dir']
  elsif node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('mapred.local.dir')
    node['hadoop']['mapred_site']['mapred.local.dir']
  else
    'file:///tmp/hadoop-mapred/local'
  end

node.default['hadoop']['mapred_site']['mapreduce.cluster.local.dir'] = mapred_local_dirs

mapred_local_dirs.split(',').each do |dir|
  directory dir.gsub('file://', '') do
    mode '0755'
    owner 'mapred'
    group 'mapred'
    action :create
    recursive true
  end
end

package pkg do
  action :nothing
end

# Hack to prevent auto-start of services, see COOK-26
ruby_block "package-#{pkg}" do
  block do
    begin
      policy_rcd('disable') if node['platform_family'] == 'debian'
      resources("package[#{pkg}]").run_action(:install)
    ensure
      policy_rcd('enable') if node['platform_family'] == 'debian'
    end
  end
  # Only CDH supports a JobTracker package
  only_if { node['hadoop']['distribution'] == 'cdh' }
end

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
  only_if { node['hadoop']['distribution'] == 'cdh' }
end

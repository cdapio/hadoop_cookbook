#
# Cookbook Name:: hadoop
# Recipe:: default
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

include_recipe 'hadoop::repo'

package "hadoop-client" do
  action :install
end

hadoop_conf_dir = "/etc/hadoop/#{node['hadoop']['conf_dir']}"

directory hadoop_conf_dir do
  mode "0755"
  owner "root"
  group "root"
  action :create
  recursive true
end

# Setup core-site.xml hadoop-policy.xml hdfs-site.xml mapred-site.xml yarn-site.xml
%w[ core_site hadoop_policy hdfs_site mapred_site yarn_site ].each do |sitefile|
  if node['hadoop'].has_key? sitefile
    myVars = { :options => node['hadoop'][sitefile] }

    template "#{hadoop_conf_dir}/#{sitefile.gsub('-','_')}.xml" do
      source "generic-site.xml.erb"
      mode "0644"
      owner "hdfs"
      group "hdfs"
      action :create
      variables myVars
    end
  end
end # End core-site.xml hadoop-policy.xml hdfs-site.xml mapred-site.xml yarn-site.xml

# Setup fair-scheduler.xml
fair_scheduler_file =
  if (node['hadoop'].has_key? 'yarn_site' \
    and node['hadoop']['yarn_site'].has_key? 'yarn.scheduler.fair.allocation.file')
    node['hadoop']['yarn_site']['yarn.scheduler.fair.allocation.file']
  else
    "#{hadoop_conf_dir}/fair-scheduler.xml"
  end

fair_scheduler_dir = File.dirname(fair_scheduler_file)

if node['hadoop'].has_key? 'fair_scheduler'
  myVars = { :options => node['hadoop']['fair_scheduler'] }

  directory fair_scheduler_dir do
    mode "0755"
    owner "hdfs"
    group "hdfs"
    action :create
    recursive true
  end

  template fair_scheduler_file do
    source "fair-scheduler.xml.erb"
    mode "0644"
    owner "hdfs"
    group "hdfs"
    action :create
    variables myVars
  end
elsif (node['hadoop'].has_key? 'yarn_site' \
  and node['hadoop']['yarn_site'].has_key? 'yarn.resourcemanager.scheduler.class' \
  and node['hadoop']['yarn_site']['yarn.resourcemanager.scheduler.class'] == \
  'org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler')
  Chef::Application.fatal!("Set YARN scheduler to fair-scheduler without configuring it, first")
end # End fair-scheduler.xml

# Setup hadoop-env.sh
if node['hadoop'].has_key? 'hadoop_env'
  myVars = { :options => node['hadoop']['hadoop_env'] }

  if (node['hadoop']['hadoop_env'].has_key? 'hadoop_log_dir')
    node['hadoop']['hadoop_env']['hadoop_log_dir'].each do |dir|
      directory dir do
        owner "hdfs"
        group "hdfs"
        mode "0755"
        action :create
      end
    end
  end

  template "#{hadoop_conf_dir}/hadoop-env.sh" do
    source "generic-env.sh.erb"
    mode "0755"
    owner "hdfs"
    group "hdfs"
    action :create
    variables myVars
  end
end # End hadoop-env.sh

# Setup hadoop-metrics.properties log4j.properties
%w[ hadoop_metrics log4j ].each do |propfile|
  if node['hadoop'].has_key? propfile
    myVars = { :properties => node['hadoop'][propfile] }

    template "#{hadoop_conf_dir}/#{propfile.gsub('-','_')}.properties" do
      source "generic.properties.erb"
      mode "0644"
      owner "hdfs"
      group "hdfs"
      action :create
      variables myVars
    end
  end
end # End hadoop-metrics.properties log4j.properties

# Set hadoop.tmp.dir
hadoop_tmp_dir =
  if (node['hadoop'].has_key 'core_site' and node['hadoop']['core_site'].has_key? 'hadoop.tmp.dir')
    node['hadoop']['core_site']['hadoop.tmp.dir']
  else
    "/tmp"
  end

directory hadoop_tmp_dir do
  mode "1777"
  action :create
end # End hadoop.tmp.dir

# Update alternatives to point to our configuration
execute "update hadoop-conf alternatives" do
  command "update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/#{node['hadoop']['conf_dir']} 50"
  not_if "update-alternatives --display hadoop-conf | grep best | awk '{print $5}' | grep /etc/hadoop/#{node['hadoop']['conf_dir']}"
end

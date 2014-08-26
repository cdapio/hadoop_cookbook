#
# Cookbook Name:: hadoop
# Recipe:: default
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

include_recipe 'hadoop::repo'

package 'hadoop-client' do
  action :install
end

hadoop_conf_dir = "/etc/hadoop/#{node['hadoop']['conf_dir']}"

directory hadoop_conf_dir do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
end

# Setup capacity-scheduler.xml core-site.xml hadoop-policy.xml hdfs-site.xml mapred-site.xml yarn-site.xml
%w(capacity_scheduler core_site hadoop_policy hdfs_site mapred_site yarn_site).each do |sitefile|
  next unless node['hadoop'].key? sitefile
  my_vars = { :options => node['hadoop'][sitefile] }

  template "#{hadoop_conf_dir}/#{sitefile.gsub('_', '-')}.xml" do
    source 'generic-site.xml.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables my_vars
  end
end # End capacity-scheduler.xml core-site.xml hadoop-policy.xml hdfs-site.xml mapred-site.xml yarn-site.xml

# Setup fair-scheduler.xml
fair_scheduler_file =
  if node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?('yarn.scheduler.fair.allocation.file')
    node['hadoop']['yarn_site']['yarn.scheduler.fair.allocation.file']
  else
    "#{hadoop_conf_dir}/fair-scheduler.xml"
  end

fair_scheduler_dir = File.dirname(fair_scheduler_file.gsub('file://', ''))

if node['hadoop'].key? 'fair_scheduler'
  # my_vars = { :options => node['hadoop']['fair_scheduler'] }
  my_vars = node['hadoop']['fair_scheduler']

  # This is a bit redundant, but necessary to pass foodcritic testing without duplicating resources
  unless fair_scheduler_dir == hadoop_conf_dir
    directory fair_scheduler_dir do
      mode '0755'
      owner 'root'
      group 'root'
      action :create
      recursive true
      not_if { fair_scheduler_dir == hadoop_conf_dir }
    end
  end

  template fair_scheduler_file.gsub('file://', '') do
    source 'fair-scheduler.xml.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables my_vars
  end
elsif node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?('yarn.resourcemanager.scheduler.class') &&
  node['hadoop']['yarn_site']['yarn.resourcemanager.scheduler.class'] == 'org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler'
  Chef::Application.fatal!('Set YARN scheduler to fair-scheduler without configuring it, first')
end # End fair-scheduler.xml

# Setup hadoop-env.sh yarn-env.sh
%w(hadoop_env yarn_env).each do |envfile|
  next unless node['hadoop'].key? envfile
  my_vars = { :options => node['hadoop'][envfile] }

  %w(hadoop yarn).each do |svc|
    next unless node['hadoop'][envfile].key? "#{svc}_log_dir"
    directory node['hadoop'][envfile]["#{svc}_log_dir"] do
      log_dir_owner =
        if svc == 'yarn'
          'yarn'
        else
          'hdfs'
        end
      owner log_dir_owner
      group log_dir_owner
      mode '0755'
      action :create
      recursive true
    end
  end

  template "#{hadoop_conf_dir}/#{envfile.gsub('_', '-')}.sh" do
    source 'generic-env.sh.erb'
    mode '0755'
    owner 'root'
    group 'root'
    action :create
    variables my_vars
  end
end # End hadoop-env.sh yarn-env.sh

# Setup hadoop-metrics.properties log4j.properties
%w(hadoop_metrics log4j).each do |propfile|
  next unless node['hadoop'].key? propfile
  my_vars = { :properties => node['hadoop'][propfile] }

  template "#{hadoop_conf_dir}/#{propfile.gsub('_', '-')}.properties" do
    source 'generic.properties.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables my_vars
  end
end # End hadoop-metrics.properties log4j.properties

# Setup container-executor.cfg
if node['hadoop'].key? 'container_executor'
  # Set container-executor.cfg options to match yarn-site.xml, if present
  if node['hadoop'].key? 'yarn_site'
    merged = node['hadoop']['yarn_site'].merge(node['hadoop']['container_executor'])
    my_vars = { :properties => merged }
  else
    my_vars = { :properties => node['hadoop']['container_executor'] }
  end

  template "#{hadoop_conf_dir}/container-executor.cfg" do
    source 'generic.properties.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables my_vars
  end
end # End container-executor.cfg

# Set hadoop.tmp.dir
hadoop_tmp_dir =
  if node['hadoop'].key?('core_site') && node['hadoop']['core_site'].key?('hadoop.tmp.dir')
    node['hadoop']['core_site']['hadoop.tmp.dir']
  else
    'file:///tmp/hadoop-${user}'
  end

node.default['hadoop']['core_site']['hadoop.tmp.dir'] = hadoop_tmp_dir

if node['hadoop']['core_site']['hadoop.tmp.dir'] == 'file:///tmp/hadoop-${user}'
  %w(hdfs mapreduce yarn).each do |dir|
    directory "/tmp/hadoop-#{dir}" do
      mode '1777'
      my_user =
        if dir == 'mapreduce'
          'mapred'
        else
          dir
        end
      owner my_user
      group my_user
      action :create
      recursive true
    end
  end
elsif node['hadoop']['core_site']['hadoop.tmp.dir'] =~ /${user}/
  # Since we're creating a 1777 directory, Hadoop can create the user-specific subdirectories, itself
  directory File.dirname(hadoop_tmp_dir.gsub('file://', '')) do
    mode '1777'
    action :create
    recursive true
  end
else
  directory hadoop_tmp_dir.gsub('file://', '') do
    mode '1777'
    action :create
    recursive true
  end
end # End hadoop.tmp.dir

# Update alternatives to point to our configuration
execute 'update hadoop-conf alternatives' do
  command "update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/#{node['hadoop']['conf_dir']} 50"
  not_if "update-alternatives --display hadoop-conf | grep best | awk '{print $5}' | grep /etc/hadoop/#{node['hadoop']['conf_dir']}"
end

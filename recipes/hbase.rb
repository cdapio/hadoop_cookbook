#
# Cookbook Name:: hadoop
# Recipe:: hbase
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
include_recipe 'hadoop::zookeeper'

package 'hbase' do
  action :install
end

# HBase needs snappy
pkg =
  case node['platform_family']
  when 'debian'
    'libsnappy1'
  when 'rhel'
    'snappy'
  end
package pkg do
  action :install
end

hbase_conf_dir = "/etc/hbase/#{node['hbase']['conf_dir']}"

directory hbase_conf_dir do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
end

# Setup hbase-policy.xml hbase-site.xml
%w(hbase_policy hbase_site).each do |sitefile|
  next unless node['hbase'].key? sitefile
  my_vars = { :options => node['hbase'][sitefile] }

  template "#{hbase_conf_dir}/#{sitefile.gsub('_', '-')}.xml" do
    source 'generic-site.xml.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables my_vars
  end
end # End hbase-policy.xml hbase-site.xml

# Setup hbase-env.sh
if node['hbase'].key? 'hbase_env'
  my_vars = { :options => node['hbase']['hbase_env'] }

  hbase_log_dir =
    if node['hbase']['hbase_env'].key? 'hbase_log_dir'
      node['hbase']['hbase_env']['hbase_log_dir']
    else
      '/var/log/hbase'
    end

  directory hbase_log_dir do
    owner 'hbase'
    group 'hbase'
    mode '0755'
    action :create
    recursive true
    only_if { node['hbase']['hbase_env'].key? 'hbase_log_dir' }
  end

  template "#{hbase_conf_dir}/hbase-env.sh" do
    source 'generic-env.sh.erb'
    mode '0755'
    owner 'hdfs'
    group 'hdfs'
    action :create
    variables my_vars
  end
end # End hbase-env.sh

# Setup hadoop-metrics.properties log4j.properties
%w(hadoop_metrics log4j).each do |propfile|
  next unless node['hbase'].key? propfile
  my_vars = { :properties => node['hbase'][propfile] }

  template "#{hbase_conf_dir}/#{propfile.gsub('_', '-')}.properties" do
    source 'generic.properties.erb'
    mode '0644'
    owner 'hbase'
    group 'hbase'
    action :create
    variables my_vars
  end
end # End hadoop-metrics.properties log4j.properties

# Update alternatives to point to our configuration
execute 'update hbase-conf alternatives' do
  command "update-alternatives --install /etc/hbase/conf hbase-conf /etc/hbase/#{node['hbase']['conf_dir']} 50"
  not_if "update-alternatives --display hbase-conf | grep best | awk '{print $5}' | grep /etc/hbase/#{node['hbase']['conf_dir']}"
end

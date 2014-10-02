#
# Cookbook Name:: hadoop
# Recipe:: spark
#
# Copyright (C) 2014 Continuuity, Inc.
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

package 'spark-core' do
  action :install
end

spark_conf_dir = "/etc/spark/#{node['spark']['conf_dir']}"

directory spark_conf_dir do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  action :create
end

if node['spark']['spark_env'].key?('spark_log_dir')
  directory node['spark']['spark_env']['spark_log_dir'] do
    owner  'spark'
    group 'spark'
    mode 00755
    recursive true
    action :create
  end
end

# TODO: /etc/spark/conf.dist/fairscheduler.xml.template

if node['spark'].key?('spark_env')
  my_vars = { :options => node['spark']['spark_env'] }

  spark_log_dir =
    if node['spark']['spark_env'].key?('spark_log_dir')
      node['spark']['spark_env']['spark_log_dir']
    else
      '/var/log/spark'
    end

  directory spark_log_dir do
    owner 'spark'
    group 'spark'
    mode 00755
    recursive true
    action :create
  end

  template "#{spark_conf_dir}/spark-env.sh" do
    source 'generic-env.sh.erb'
    mode 00755
    owner 'root'
    group 'root'
    action :create
    variables my_vars
  end
end # End spark-env.sh

if node['spark'].key?('spark_defaults')
  my_vars = { :options => node['spark']['spark_defaults'] }

  template "#{spark_conf_dir}/spark-defaults.xml" do
    source 'generic-site.xml.erb'
    mode 00644
    owner 'root'
    group 'root'
    variables my_vars
  end
end

# Setup metrics.properties log4j.properties
%w(metrics log4j).each do |propfile|
  if node['spark'].key? propfile
    my_vars = { :properties => node['spark'][propfile] }

    template "#{spark_conf_dir}/#{propfile.gsub('_', '-')}.properties" do
      source 'generic.properties.erb'
      mode 00644
      owner 'spark'
      group 'spark'
      action :create
      variables my_vars
    end
  end
end # End metrics.properties log4j.properties

# Update alternatives to point to our configuration
execute 'update spark-conf alternatives' do
  command "update-alternatives --install /etc/spark/conf spark-conf /etc/spark/#{node['spark']['conf_dir']} 50"
  not_if "update-alternatives --display spark-conf | grep best | awk '{print $5}' | grep /etc/spark/#{node['spark']['conf_dir']}"
end
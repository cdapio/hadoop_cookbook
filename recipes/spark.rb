#
# Cookbook Name:: hadoop
# Recipe:: spark
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

%w( hadoop-client scala spark-core ).each do |pkg|
  package pkg do
    action :install
  end
end

spark_conf_dir = '/etc/spark/conf'

if node['spark']['spark_env'].key?('spark_log_dir')
  directory node['spark']['spark_env']['spark_log_dir'] do
    owner  'spark'
    group  'spark'
    mode   00755
    action :create
  end
end

if node['spark'].key?('spark_env')
  my_vars = { :options => node['spark']['spark_env'] }

  spark_log_dir =
    if node['spark']['spark_env'].key?('spark_log_dir')
      node['spark']['spark_env']['spark_log_dir']
    else
      '/var/log/spark'
    end

  directory spark_log_dir do
    owner  'spark'
    group  'spark'
    mode   00755
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
end

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

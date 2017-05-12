#
# Cookbook Name:: hadoop
# Recipe:: spark2
#
# Copyright © 2013-2017 Cask Data, Inc.
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

pkg =
  if node['hadoop']['distribution'] == 'cdh'
    'spark2-core'
  elsif iop?
    hadoop_package('spark2-core')
  else
    hadoop_package('spark2')
  end

package pkg do
  action :install
end

package hadoop_package('spark2-python') do
  action :install
end

# Spark MLib requires this
fortran_libs =
  if node['platform_family'] == 'debian'
    'libgfortran3'
  else
    'libgfortran'
  end
package fortran_libs do
  action :install
end

spark2_conf_dir = "/etc/spark2/#{node['spark2']['conf_dir']}"

directory spark2_conf_dir do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# TODO: /etc/spark2/conf.dist/fairscheduler.xml.template

spark2_log_dir =
  if node['spark2'].key?('spark_env') && node['spark2']['spark_env'].key?('spark_log_dir')
    node['spark2']['spark_env']['spark_log_dir']
  else
    '/var/log/spark2'
  end

directory spark2_log_dir do
  owner 'spark'
  group 'spark'
  mode '0755'
  recursive true
  action :create
  only_if { node['spark2'].key?('spark_env') && node['spark2']['spark_env'].key?('spark_log_dir') }
end

unless spark2_log_dir == '/var/log/spark2'
  # Delete default directory, if we aren't set to it
  directory '/var/log/spark2' do
    action :delete
    recursive true
    not_if 'test -L /var/log/spark2'
  end
  # symlink
  link '/var/log/spark2' do
    to spark2_log_dir
  end
end

# Start spark-env.sh
template "#{spark2_conf_dir}/spark-env.sh" do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: node['spark2']['spark_env']
  only_if { node['spark2'].key?('spark_env') && !node['spark2']['spark_env'].empty? }
end # End spark-env.sh

# Start spark-defaults.conf
template "#{spark2_conf_dir}/spark-defaults.conf" do
  source 'generic.properties.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables properties: node['spark2']['spark_defaults']
  only_if { node['spark2'].key?('spark_defaults') && !node['spark2']['spark_defaults'].empty? }
end # End spark-defaults.conf

# Setup metrics.properties log4j.properties
%w(metrics log4j).each do |propfile|
  template "#{spark2_conf_dir}/#{propfile.tr('_', '-')}.properties" do
    source 'generic.properties.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables properties: node['spark2'][propfile]
    only_if { node['spark2'].key?(propfile) && !node['spark2'][propfile].empty? }
  end
end # End metrics.properties log4j.properties

# Another Hortonworks mess to clean up, their packages force-install blank configs here
directory '/etc/spark2/conf' do
  action :delete
  recursive true
  not_if 'test -L /etc/spark2/conf'
end

# Update alternatives to point to our configuration
execute 'update spark2-conf alternatives' do
  command "update-alternatives --install /etc/spark2/conf spark-conf /etc/spark2/#{node['spark2']['conf_dir']} 50"
  not_if "update-alternatives --display spark2-conf | grep best | awk '{print $5}' | grep /etc/spark2/#{node['spark2']['conf_dir']}"
end

# Export spark2 environment variables
template '/etc/profile.d/spark2.sh' do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  variables options: { 'spark2_conf_dir' => "/etc/spark2/#{node['spark2']['conf_dir']}" }
end

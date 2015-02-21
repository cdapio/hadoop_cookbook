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

include_recipe 'hadoop::repo'

package 'spark-core' do
  action :install
  only_if { node['hadoop']['distribution'] == 'cdh' }
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

unless node['spark']['release']['install'] == false

  # Spark binary compatibility matrix
  case node['hadoop']['distribution']
  when 'cdh'
    if node['hadoop']['distribution_version'].to_i == 4
      spark_release = 'cdh4'
    elsif node['hadoop']['distribution_version'].to_f == 5.0 || node['hadoop']['distribution_version'].to_f == 5.1
      spark_release = 'hadoop2.3'
    else
      spark_release = 'hadoop2.4'
    end
  when 'hdp'
    if node['hadoop']['distribution_version'] == '2' || node['hadoop']['distribution_version'].to_f == 2.1
      spark_release = 'hadoop2.4'
    else
      ### TODO: HDP 2.0 is Hadoop 2.2... does 2.3 work?
      spark_release = 'hadoop2.3'
    end
  end

  remote_file "#{node['spark']['release']['install_path']}/spark-#{node['spark']['release']['version']}-bin-#{spark_release}.tgz" do
    source "http://d3kbcqa49mib13.cloudfront.net/spark-#{node['spark']['release']['version']}-bin-#{spark_release}.tgz"
    checksum node['spark']['release']['checksum']
    not_if { ::File.exist?("#{node['spark']['release']['install_path']}/spark-#{node['spark']['release']['version']}-bin-#{spark_release}.tgz") }
    action :create_if_missing
  end

  execute 'install-spark-release' do
    cwd node['spark']['release']['install_path']
    user 'root'
    group 'root'
    command "tar -xvzf spark-#{node['spark']['release']['version']}-bin-#{spark_release}.tgz"
    not_if "test -d #{node['spark']['release']['install_path']}/spark-#{node['spark']['release']['version']}-bin-#{spark_release}"
    action :run
  end

  link "#{node['spark']['release']['install_path']}/spark" do
    to "#{node['spark']['release']['install_path']}/spark-#{node['spark']['release']['version']}-bin-#{spark_release}"
    action :create
  end

  # override SPARK_HOME to use release install
  node.override['spark']['spark_env']['spark_home'] = "#{node['spark']['release']['install_path']}/spark"
end

spark_conf_dir = "/etc/spark/#{node['spark']['conf_dir']}"

directory spark_conf_dir do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
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
    mode '0755'
    recursive true
    action :create
    only_if { node['spark']['spark_env'].key?('spark_log_dir') }
  end

  unless spark_log_dir == '/var/log/spark'
    # Delete default directory, if we aren't set to it
    directory '/var/log/spark' do
      action :delete
      recursive true
      not_if 'test -L /var/log/spark'
    end
    # symlink
    link '/var/log/spark' do
      to spark_log_dir
    end
  end

  template "#{spark_conf_dir}/spark-env.sh" do
    source 'generic-env.sh.erb'
    mode '0755'
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
    mode '0644'
    owner 'root'
    group 'root'
    variables my_vars
  end
end

# Setup metrics.properties log4j.properties
%w(metrics log4j).each do |propfile|
  next unless node['spark'].key?(propfile)
  my_vars = { :properties => node['spark'][propfile] }

  template "#{spark_conf_dir}/#{propfile.gsub('_', '-')}.properties" do
    source 'generic.properties.erb'
    mode '0644'
    owner 'spark'
    group 'spark'
    action :create
    variables my_vars
  end
end # End metrics.properties log4j.properties

# Update alternatives to point to our configuration
execute 'update spark-conf alternatives' do
  command "update-alternatives --install /etc/spark/conf spark-conf /etc/spark/#{node['spark']['conf_dir']} 50"
  not_if "update-alternatives --display spark-conf | grep best | awk '{print $5}' | grep /etc/spark/#{node['spark']['conf_dir']}"
end

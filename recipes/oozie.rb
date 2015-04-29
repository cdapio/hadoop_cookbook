#
# Cookbook Name:: hadoop
# Recipe:: oozie
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

include_recipe 'hadoop::repo'
include_recipe 'hadoop::oozie_client'
pkg = 'oozie'

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

oozie_conf_dir = "/etc/oozie/#{node['oozie']['conf_dir']}"
oozie_data_dir = '/var/lib/oozie'
java_share_dir = '/usr/share/java'

case node['platform_family']
when 'debian'
  pkgs = %w(
    libmysql-java
    libpostgresql-jdbc-java
  )
  jars = %w(
    mysql-connector-java
    postgresql-jdbc4
  )
when 'rhel'
  case node['platform_version'].to_i
  when 6
    pkgs = %w(
      mysql-connector-java
      postgresql-jdbc
    )
    jars = pkgs
  else
    Chef::Log.warn('You must download and install JDBC connectors')
    pkgs = nil
  end
end

pkgs.each do |p|
  package p do
    action :install
  end
end

jars.each do |jar|
  link "#{oozie_data_dir}/#{jar}.jar" do
    to "#{java_share_dir}/#{jar}.jar"
  end
end

package 'unzip'

extjs = 'ext-2.2.zip'
remote_file "#{oozie_data_dir}/#{extjs}" do
  source "http://extjs.com/deploy/#{extjs}"
  mode '0644'
  action :create_if_missing
end

script 'extract extjs into Oozie data directory' do
  interpreter 'bash'
  user 'root'
  action :nothing
  code "unzip -o -d #{oozie_data_dir} #{oozie_data_dir}/#{extjs}"
  subscribes :run, "remote_file[#{oozie_data_dir}/#{extjs}]", :immediately
end

directory oozie_conf_dir do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
end

if node['oozie'].key?('oozie_site')
  my_vars = { :options => node['oozie']['oozie_site'] }

  template "#{oozie_conf_dir}/oozie-site.xml" do
    source 'generic-site.xml.erb'
    mode '0644'
    owner 'oozie'
    group 'oozie'
    action :create
    variables my_vars
  end
end

# Setup oozie-env.sh
if node['oozie'].key?('oozie_env')
  my_vars = { :options => node['oozie']['oozie_env'] }

  oozie_log_dir =
    if node['oozie']['oozie_env'].key?('oozie_log_dir')
      node['oozie']['oozie_env']['oozie_log_dir']
    else
      '/var/log/oozie'
    end

  directory oozie_log_dir do
    owner 'oozie'
    group 'oozie'
    mode '0755'
    action :create
    recursive true
    only_if { node['oozie']['oozie_env'].key?('oozie_log_dir') }
  end

  unless oozie_log_dir == '/var/log/oozie'
    # Delete default directory, if we aren't set to it
    directory '/var/log/oozie' do
      action :delete
      recursive true
      not_if 'test -L /var/log/oozie'
    end
    # symlink
    link '/var/log/oozie' do
      to oozie_log_dir
    end
  end

  template "#{oozie_conf_dir}/oozie-env.sh" do
    source 'generic-env.sh.erb'
    mode '0755'
    owner 'root'
    group 'root'
    action :create
    variables my_vars
  end
end # End oozie-env.sh

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end

# Update alternatives to point to our configuration
execute 'update oozie-conf alternatives' do
  command "update-alternatives --install /etc/oozie/conf oozie-conf /etc/oozie/#{node['oozie']['conf_dir']} 50"
  not_if "update-alternatives --display oozie-conf | grep best | awk '{print $5}' | grep /etc/oozie/#{node['oozie']['conf_dir']}"
end

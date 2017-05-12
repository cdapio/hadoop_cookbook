#
# Cookbook:: hadoop
# Recipe:: hadoop_kms
#
# Copyright © 2016 Cask Data, Inc.
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

# This service is only supported on CDH, so far
package 'hadoop-kms' do
  action :install
  only_if { node['hadoop']['distribution'] == 'cdh' }
end

# Configs: hadoop-kms-conf = /etc/hadoop-kms/conf

hadoop_kms_conf_dir = "/etc/hadoop-kms/#{node['hadoop_kms']['conf_dir']}"

directory hadoop_kms_conf_dir do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
end

# Hadoop KMS doesn't read Hadoop's config, but we may need core-site, so we merge hadoop['core_site'], allowing overrides
merge1 = node['hadoop']['core_site'] || {}
merge2 = node['hadoop_kms']['core_site'] || {}
node.default['hadoop_kms']['core_site'] = merge1.merge(merge2)

# Setup core-site.xml kms-acls.xml kms-site.xml
%w(core_site kms_acls kms_site).each do |sitefile|
  template "#{hadoop_kms_conf_dir}/#{sitefile.tr('_', '-')}.xml" do
    source 'generic-site.xml.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables options: node['hadoop_kms'][sitefile]
    only_if { node['hadoop_kms'].key?(sitefile) && !node['hadoop_kms'][sitefile].empty? }
  end
end # End core-site.xml kms-acls.xml kms-site.xml

hadoop_kms_log_dir =
  if node['hadoop_kms'].key?('kms_env') && node['hadoop_kms']['kms_env'].key?('kms_log')
    node['hadoop_kms']['kms_env']['kms_log']
  else
    '/var/log/hadoop-kms'
  end

directory hadoop_kms_log_dir do
  owner 'kms'
  group 'kms'
  mode '0755'
  action :create
  recursive true
  only_if { node['hadoop_kms'].key?('kms_env') && node['hadoop_kms']['kms_env'].key?('kms_log') }
end

unless hadoop_kms_log_dir == '/var/log/hadoop-kms'
  # Delete default directory, if we aren't set to it
  directory '/var/log/hadoop-kms' do
    action :delete
    recursive true
    not_if 'test -L /var/log/hadoop-kms'
  end
  # symlink
  link '/var/log/hadoop-kms' do
    to hadoop_kms_log_dir
  end
end

# Setup kms-env.sh
template "#{hadoop_kms_conf_dir}/kms-env.sh" do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'hdfs'
  group 'hdfs'
  action :create
  variables options: node['hadoop_kms']['kms_env']
  only_if { node['hadoop_kms'].key?('kms_env') && !node['hadoop_kms']['kms_env'].empty? }
end # End kms-env.sh

# Setup kms-log4j.properties
template "#{hadoop_kms_conf_dir}/kms-log4j.properties" do
  source 'generic.properties.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables properties: node['hadoop_kms']['log4j']
  only_if { node['hadoop_kms'].key?('log4j') && !node['hadoop_kms']['log4j'].empty? }
end # End kms-log4j.properties

# Update alternatives to point to our configuration
execute 'update hadoop-kms-conf alternatives' do
  command "update-alternatives --install /etc/hadoop-kms/conf hadoop-kms-conf /etc/hadoop-kms/#{node['hadoop_kms']['conf_dir']} 50"
  not_if "update-alternatives --display hadoop-kms-conf | grep best | awk '{print $5}' | grep /etc/hadoop-kms/#{node['hadoop_kms']['conf_dir']}"
end

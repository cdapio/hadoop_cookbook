#
# Cookbook:: hadoop
# Recipe:: hbase
#
# Copyright © 2013-2016 Cask Data, Inc.
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
include_recipe 'hadoop::_compression_libs'

package hadoop_package('hbase') do
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
  my_vars = { options: node['hbase'][sitefile] }

  template "#{hbase_conf_dir}/#{sitefile.tr('_', '-')}.xml" do
    source 'generic-site.xml.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables my_vars
    only_if { node['hbase'].key?(sitefile) && !node['hbase'][sitefile].empty? }
  end
end # End hbase-policy.xml hbase-site.xml

# Setup hbase-env.sh
my_vars = { options: node['hbase']['hbase_env'] }

hbase_log_dir =
  if node['hbase'].key?('hbase_env') && node['hbase']['hbase_env'].key?('hbase_log_dir')
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
  only_if { node['hbase'].key?('hbase_env') && node['hbase']['hbase_env'].key?('hbase_log_dir') }
end

unless hbase_log_dir == '/var/log/hbase'
  # Delete default directory, if we aren't set to it
  directory '/var/log/hbase' do
    action :delete
    recursive true
    not_if 'test -L /var/log/hbase'
  end
  # symlink
  link '/var/log/hbase' do
    to hbase_log_dir
  end
end

template "#{hbase_conf_dir}/hbase-env.sh" do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'hdfs'
  group 'hdfs'
  action :create
  variables my_vars
  only_if { node['hbase'].key?('hbase_env') && !node['hbase']['hbase_env'].empty? }
end # End hbase-env.sh

# Setup hadoop-metrics.properties log4j.properties
%w(hadoop_metrics log4j).each do |propfile|
  my_vars = { properties: node['hbase'][propfile] }

  template "#{hbase_conf_dir}/#{propfile.tr('_', '-')}.properties" do
    source 'generic.properties.erb'
    mode '0644'
    owner 'hbase'
    group 'hbase'
    action :create
    variables my_vars
    only_if { node['hbase'].key?(propfile) && !node['hbase'][propfile].empty? }
  end
end # End hadoop-metrics.properties log4j.properties

write_deprecated_jaas_config('hbase')
write_jaas_config('hbase')

# limits.d settings
ulimit_domain 'hbase' do
  node['hbase']['limits'].each do |k, v|
    rule do
      item k
      type '-'
      value v
    end
  end
  only_if { node['hbase'].key?('limits') && !node['hbase']['limits'].empty? }
end # End limits.d

# Create /etc/default configuration
template '/etc/default/hbase' do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'hbase_home' => "#{hadoop_lib_dir}/hbase",
    'hbase_pid_dir' => '/var/run/hbase',
    'hbase_log_dir' => hbase_log_dir,
    'hbase_ident_string' => 'hbase',
    'hbase_conf_dir' => '/etc/hbase/conf',
  }
end

# Another Hortonworks mess to clean up, their packages force-install blank configs here
directory '/etc/hbase/conf' do
  action :delete
  recursive true
  not_if 'test -L /etc/hbase/conf'
end

# Update alternatives to point to our configuration
execute 'update hbase-conf alternatives' do
  command "update-alternatives --install /etc/hbase/conf hbase-conf /etc/hbase/#{node['hbase']['conf_dir']} 50"
  not_if "update-alternatives --display hbase-conf | grep best | awk '{print $5}' | grep /etc/hbase/#{node['hbase']['conf_dir']}"
end

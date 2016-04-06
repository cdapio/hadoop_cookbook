#
# Cookbook Name:: hadoop
# Recipe:: hive
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

package hadoop_package('hive') do
  action :install
end

hive_conf_dir = "/etc/hive/#{node['hive']['conf_dir']}"

directory hive_conf_dir do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
end

directory '/var/lib/hive' do
  mode '0755'
  owner 'hive'
  group 'hive'
  action :create
end

local_scratch_dir =
  if node['hive'].key?('hive_site') && node['hive']['hive_site'].key?('hive.exec.local.scratchdir')
    node['hive']['hive_site']['hive.exec.local.scratchdir']
  else
    '/tmp/${user.name}'
  end

node.default['hive']['hive_site']['hive.exec.local.scratchdir'] = local_scratch_dir

directory local_scratch_dir.gsub('${user.name}', 'hive') do
  mode '1777'
  owner 'hive'
  group 'hive'
  action :create
  only_if { local_scratch_dir != '/tmp/${user.name}' }
end

# Setup hive-site.xml
template "#{hive_conf_dir}/hive-site.xml" do
  source 'generic-site.xml.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables :options => node['hive']['hive_site']
  only_if { node['hive'].key?('hive_site') && !node['hive']['hive_site'].empty? }
end # End hive-site.xml

# Setup HIVE_LOG_DIR
hive_log_dir =
  if node['hive'].key?('hive_env') && node['hive']['hive_env'].key?('hive_log_dir')
    node['hive']['hive_env']['hive_log_dir']
  else
    '/var/log/hive'
  end

directory hive_log_dir do
  owner 'hive'
  group 'hive'
  mode '0755'
  action :create
  recursive true
  only_if { node['hive'].key?('hive_env') && node['hive']['hive_env'].key?('hive_log_dir') }
end

unless hive_log_dir == '/var/log/hive'
  # Delete default directory, if we aren't set to it
  directory '/var/log/hive' do
    action :delete
    recursive true
    not_if 'test -L /var/log/hive'
  end
  # symlink
  link '/var/log/hive' do
    to hive_log_dir
  end
end

# Setup hive-env.sh
template "#{hive_conf_dir}/hive-env.sh" do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'hive'
  group 'hive'
  action :create
  variables :options => node['hive']['hive_env']
  only_if { node['hive'].key?('hive_env') && !node['hive']['hive_env'].empty? }
end # End hive-env.sh

# Create Hive user's home in HDFS
dfs = node['hadoop']['core_site']['fs.defaultFS']
execute 'hive-hdfs-homedir' do
  command "hdfs dfs -mkdir -p #{dfs}/user/hive && hdfs dfs -chown hive:hdfs #{dfs}/user/hive"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{dfs}/user/hive", :user => 'hdfs'
  action :nothing
end

# Another Hortonworks mess to clean up, their packages force-install blank configs here
directory '/etc/hive/conf' do
  action :delete
  recursive true
  not_if 'test -L /etc/hive/conf'
end

# Update alternatives to point to our configuration
execute 'update hive-conf alternatives' do
  command "update-alternatives --install /etc/hive/conf hive-conf /etc/hive/#{node['hive']['conf_dir']} 50"
  not_if "update-alternatives --display hive-conf | grep best | awk '{print $5}' | grep /etc/hive/#{node['hive']['conf_dir']}"
end

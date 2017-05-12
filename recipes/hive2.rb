#
# Cookbook:: hadoop
# Recipe:: hive2
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

package hadoop_package('hive2') do
  action :install
end

hive2_conf_dir = "/etc/hive2/#{node['hive2']['conf_dir']}"

directory hive2_conf_dir do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
end

directory '/var/lib/hive2' do
  mode '0755'
  owner 'hive'
  group 'hive'
  action :create
end

local_scratch_dir =
  if node['hive2'].key?('hive_site') && node['hive2']['hive_site'].key?('hive.exec.local.scratchdir')
    node['hive2']['hive_site']['hive.exec.local.scratchdir']
  else
    '/tmp/${user.name}'
  end

node.default['hive2']['hive_site']['hive.exec.local.scratchdir'] = local_scratch_dir

directory local_scratch_dir.gsub('${user.name}', 'hive') do
  mode '1777'
  owner 'hive'
  group 'hive'
  action :create
  only_if { local_scratch_dir != '/tmp/${user.name}' }
end

# Setup hive-site.xml
template "#{hive2_conf_dir}/hive-site.xml" do
  source 'generic-site.xml.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables options: node['hive2']['hive_site']
  only_if { node['hive2'].key?('hive_site') && !node['hive2']['hive_site'].empty? }
end # End hive-site.xml

# Setup HIVE_LOG_DIR
hive2_log_dir =
  if node['hive2'].key?('hive_env') && node['hive2']['hive_env'].key?('hive_log_dir')
    node['hive2']['hive_env']['hive_log_dir']
  else
    '/var/log/hive2'
  end

directory hive2_log_dir do
  owner 'hive'
  group 'hive'
  mode '0755'
  action :create
  recursive true
  only_if { node['hive2'].key?('hive_env') && node['hive2']['hive_env'].key?('hive_log_dir') }
end

unless hive2_log_dir == '/var/log/hive2'
  # Delete default directory, if we aren't set to it
  directory '/var/log/hive2' do
    action :delete
    recursive true
    not_if 'test -L /var/log/hive2'
  end
  # symlink
  link '/var/log/hive2' do
    to hive2_log_dir
  end
end

# Setup hive-env.sh
template "#{hive2_conf_dir}/hive-env.sh" do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'hive'
  group 'hive'
  action :create
  variables options: node['hive2']['hive_env']
  only_if { node['hive2'].key?('hive_env') && !node['hive2']['hive_env'].empty? }
end # End hive-env.sh

# Setup beeline-log4j2.properties hive-exec-log4j2.properties hive-log4j2.properties llap-cli-log4j2.properties llap-daemon-log4j2.properties
%w(beeline_log4j2 hive_exec_log4j2 hive_log4j2 llap_cli_log4j2 llap_daemon_log4j2).each do |propfile|
  template "#{hive2_conf_dir}/#{propfile.tr('_', '-')}.properties" do
    source 'generic.properties.erb'
    mode '0644'
    owner 'hive'
    group 'hive'
    action :create
    variables properties: node['hive2'][propfile]
    only_if { node['hive2'].key?(propfile) && !node['hive2'][propfile].empty? }
  end
end # beeline-log4j2.properties hive-exec-log4j2.properties hive-log4j2.properties llap-cli-log4j2.properties llap-daemon-log4j2.properties

# Create Hive user's home in HDFS
dfs = node['hadoop']['core_site']['fs.defaultFS']
execute 'hive2-hdfs-homedir' do
  command "hdfs dfs -mkdir -p #{dfs}/user/hive && hdfs dfs -chown hive:hdfs #{dfs}/user/hive"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{dfs}/user/hive", user: 'hdfs'
  action :nothing
end

# Another Hortonworks mess to clean up, their packages force-install blank configs here
directory '/etc/hive2/conf' do
  action :delete
  recursive true
  not_if 'test -L /etc/hive2/conf'
end

# Update alternatives to point to our configuration
execute 'update hive2-conf alternatives' do
  command "update-alternatives --install /etc/hive2/conf hive2-conf /etc/hive2/#{node['hive2']['conf_dir']} 50"
  not_if "update-alternatives --display hive2-conf | grep best | awk '{print $5}' | grep /etc/hive2/#{node['hive2']['conf_dir']}"
end

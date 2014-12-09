#
# Cookbook Name:: hadoop
# Recipe:: tez
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

package 'tez' do
  action :install
  only_if { node['hadoop']['distribution'] == 'hdp' }
end

# Copy tez library into HDFS
dfs = node['hadoop']['core_site']['fs.defaultFS']
execute 'tez-hdfs-appdir' do
  command <<-EOS
  hdfs dfs -mkdir -p #{dfs}/apps/tez && \
  hdfs dfs -copyFromLocal /usr/lib/tez/* #{dfs}/apps/tez && \
  hdfs dfs -chown -R  hdfs:users #{dfs}/apps/tez && \
  hdfs dfs -chmod 755 #{dfs}/apps && \
  hdfs dfs -chmod 755 #{dfs}/apps/tez && \
  hdfs dfs -chmod 755 #{dfs}/apps/tez/lib && \
  hdfs dfs -chmod 644 #{dfs}/apps/tez/*.jar && \
  hdfs dfs -chmod 644 #{dfs}/apps/tez/lib/*.jar
  EOS
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{dfs}/apps/tez", :user => 'hdfs'
  action :nothing
end

tez_conf_dir = "/etc/tez/#{node['tez']['conf_dir']}"

directory tez_conf_dir do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
end

# Setup tez-site.xml
if node['tez'].key?('tez_site')
  my_vars = { :options => node['tez']['tez_site'] }

  template "#{tez_conf_dir}/tez-site.xml" do
    source 'generic-site.xml.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables my_vars
  end
end # End tez-site.xml

# Setup tez-env.sh
if node['tez'].key?('tez_env')
  my_vars = { :options => node['tez']['tez_env'] }

  template "#{tez_conf_dir}/tez-env.sh" do
    source 'generic-env.sh.erb'
    mode '0755'
    owner 'root'
    group 'root'
    action :create
    variables my_vars
  end
end # End tez-env.sh

# Update alternatives to point to our configuration
execute 'update tez-conf alternatives' do
  command "update-alternatives --install /etc/tez/conf tez-conf /etc/tez/#{node['tez']['conf_dir']} 50"
  not_if "update-alternatives --display tez-conf | grep best | awk '{print $5}' | grep /etc/tez/#{node['tez']['conf_dir']}"
end

if node.recipe?('hadoop::hive') && node['hive']['hive_site']['hive.execution.engine'] == 'tez'
  execute 'hive-hdfs-appdir' do
    command <<-EOS
    hdfs dfs -mkdir -p #{dfs}/apps/hive/install && \
    hdfs dfs -copyFromLocal /usr/lib/hive/lib/hive-exec-* #{dfs}/apps/hive/install/
    EOS
    timeout 300
    user 'hdfs'
    group 'hdfs'
    not_if "hdfs dfs -test -d #{dfs}/apps/hive/install", :user => 'hdfs'
    action :nothing
  end
end

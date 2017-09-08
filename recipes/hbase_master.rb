#
# Cookbook:: hadoop
# Recipe:: hbase_master
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

include_recipe 'hadoop::hbase'
include_recipe 'hadoop::_hbase_checkconfig'
include_recipe 'hadoop::_system_tuning'
pkg = 'hbase-master'

# HBase can use a local directory or an HDFS directory for its rootdir...
# if HDFS, create execute block with action :nothing
# else create the local directory when file://
### TODO: do not create resources via conditionals, use guards
if node['hbase'].key?('hbase_site') && node['hbase']['hbase_site'].key?('hbase.rootdir') &&
   node['hbase']['hbase_site']['hbase.rootdir'] =~ %r{^hdfs://} || (node['hbase']['hbase_site']['hbase.rootdir'] =~ %r{^/} &&
  node['hbase']['hbase_site']['hbase.cluster.distributed'].to_s == 'true')
  execute 'hbase-hdfs-rootdir' do
    command "hdfs dfs -mkdir -p #{node['hbase']['hbase_site']['hbase.rootdir']} && hdfs dfs -chown hbase #{node['hbase']['hbase_site']['hbase.rootdir']}"
    timeout 300
    user 'hdfs'
    group 'hdfs'
    not_if "hdfs dfs -test -d #{node['hbase']['hbase_site']['hbase.rootdir']}", user: 'hdfs'
    action :nothing
  end
elsif node['hbase']['hbase_site']['hbase.rootdir'] =~ %r{^/|^file://}
  directory node['hbase']['hbase_site']['hbase.rootdir'].gsub('file://', '') do
    owner 'hbase'
    group 'hbase'
    mode '0700'
    action :create
    recursive true
  end
else
  Chef::Application.fatal!("node['hbase']['hbase_site']['hbase.rootdir'] must be set to file:// or hdfs:// locations")
end

# https://hbase.apache.org/book/hbase.secure.bulkload.html
bulkload_dir =
  if node['hbase']['hbase_site'].key?('hbase.bulkload.staging.dir')
    node['hbase']['hbase_site']['hbase.bulkload.staging.dir']
  else
    '/tmp/hbase-staging'
  end

node.default['hbase']['hbase_site']['hbase.bulkload.staging.dir'] = bulkload_dir

execute 'hbase-bulkload-stagingdir' do
  command "hdfs dfs -mkdir -p #{bulkload_dir} && hdfs dfs -chown hbase:hbase #{bulkload_dir} && hdfs dfs -chmod 711 #{bulkload_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{bulkload_dir}", user: 'hdfs'
  action :nothing
end

hbase_log_dir =
  if node['hbase'].key?('hbase_env') && node['hbase']['hbase_env'].key?('hbase_log_dir')
    node['hbase']['hbase_env']['hbase_log_dir']
  else
    '/var/log/hbase'
  end

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0644'
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

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'desc' => 'HBase Master',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{hadoop_lib_dir}/hbase/bin/hbase-daemon.sh",
    'args' => '--config ${CONF_DIR} start master',
    'confdir' => '${HBASE_CONF_DIR}',
    'user' => 'hbase',
    'home' => "#{hadoop_lib_dir}/hbase",
    'pidfile' => "${HBASE_PID_DIR}/hbase-#{pkg}.pid",
    'logfile' => "${HBASE_LOG_DIR}/#{pkg}.log",
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action :nothing
end

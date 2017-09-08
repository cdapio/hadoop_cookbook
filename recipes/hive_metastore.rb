#
# Cookbook:: hadoop
# Recipe:: hive_metastore
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

include_recipe 'hadoop::hive'
include_recipe 'hadoop::_system_tuning'
pkg = 'hive-metastore'

hive_sql =
  if node['hive'].key?('hive_site') && node['hive']['hive_site'].key?('javax.jdo.option.ConnectionURL')
    node['hive']['hive_site']['javax.jdo.option.ConnectionURL'].split(':')[1]
  else
    'derby'
  end

node.default['hadoop']['sql_connector'] = hive_sql
include_recipe 'hadoop::_sql_connectors'

java_share_dir = '/usr/share/java'
jars = node['hadoop']['sql_jars']

jars.each do |jar|
  link "#{hadoop_lib_dir}/hive/lib/#{jar}.jar" do
    to "#{java_share_dir}/#{jar}.jar"
  end
end

derby_db =
  if hive_sql == 'derby' && node['hive'].key?('hive_site') && node['hive']['hive_site'].key?('javax.jdo.option.ConnectionURL')
    node['hive']['hive_site']['javax.jdo.option.ConnectionURL'].split(':')[2].split(';').find { |o| /^databaseName/ =~ o }.split('=')[1]
  else
    # We set this to our default, because the Hive default uses the current working directory
    '/var/lib/hive/metastore/metastore_db'
  end

directory ::File.dirname(derby_db) do
  action :create
end

# Hive HDFS directories
dfs = node['hadoop']['core_site']['fs.defaultFS']
warehouse_dir =
  if node['hive'].key?('hive_site') && node['hive']['hive_site'].key?('hive.metastore.warehouse.dir')
    node['hive']['hive_site']['hive.metastore.warehouse.dir']
  else
    '/user/hive/warehouse'
  end

scratch_dir =
  if node['hive'].key?('hive_site') && node['hive']['hive_site'].key?('hive.exec.scratchdir')
    node['hive']['hive_site']['hive.exec.scratchdir']
  else
    '/tmp/hive-${user.name}'
  end

node.default['hive']['hive_site']['hive.exec.scratchdir'] = scratch_dir
node.default['hive']['hive_site']['hive.metastore.warehouse.dir'] = warehouse_dir

unless scratch_dir == '/tmp/hive-${user.name}'
  execute 'hive-hdfs-scratchdir' do
    command "hdfs dfs -mkdir -p #{dfs}/#{scratch_dir} && hdfs dfs -chown hive:hive #{dfs}/#{scratch_dir} && hdfs dfs -chmod 777 #{dfs}/#{scratch_dir}"
    timeout 300
    user 'hdfs'
    group 'hdfs'
    not_if "hdfs dfs -test -d #{dfs}/#{scratch_dir}", user: 'hdfs'
    action :nothing
  end
end

execute 'hive-hdfs-warehousedir' do
  command "hdfs dfs -mkdir -p #{dfs}/#{warehouse_dir} && hdfs dfs -chown hive:hive #{dfs}/#{warehouse_dir} && hdfs dfs -chmod 1777 #{dfs}/#{warehouse_dir}"
  timeout 300
  user 'hdfs'
  group 'hdfs'
  not_if "hdfs dfs -test -d #{dfs}/#{warehouse_dir}", user: 'hdfs'
  action :nothing
end

hive_log_dir =
  if node['hive'].key?('hive_env') && node['hive']['hive_env'].key?('hive_log_dir')
    node['hive']['hive_env']['hive_log_dir']
  else
    '/var/log/hive'
  end

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'hive_home' => "#{hadoop_lib_dir}/hive",
    'hive_pid_dir' => '/var/run/hive',
    'hive_log_dir' => hive_log_dir,
    'hive_ident_string' => 'hive',
    'hive_conf_dir' => '/etc/hive/conf',
  }
end

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'desc' => 'Hive MetaStore',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{hadoop_lib_dir}/hive/bin/hive",
    'args' => '--config ${CONF_DIR} --service metastore > ${LOG_FILE} 2>&1 < /dev/null &',
    'confdir' => '${HIVE_CONF_DIR}',
    'user' => 'hive',
    'home' => "#{hadoop_lib_dir}/hive",
    'pidfile' => "${HIVE_PID_DIR}/#{pkg}.pid",
    'logfile' => "${HIVE_LOG_DIR}/#{pkg}.log",
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action :nothing
end

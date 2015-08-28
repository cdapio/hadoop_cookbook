#
# Cookbook Name:: hadoop
# Recipe:: hcatalog
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

include_recipe 'hadoop::hive'
include_recipe 'hadoop::_system_tuning'

# rubocop:disable UselessAssignment
case node['hadoop']['distribution']
when 'cdh'
  case node['hadoop']['distribution_version'].to_i
  when 4
    pkgs = %w(hcatalog hcatalog-server)
    svcs = %w(hcatalog-server)
  when 5
    pkgs = %w(hive-hcatalog)
    svcs = %w(hive-hcatalog)
  end
when 'hdp'
  case node['hadoop']['distribution_version'].to_f
  when 2.0
    pkgs = %w(hcatalog)
  else
    pkgs = %w(hive-hcatalog)
  end
  svcs = []
end
# rubocop:enable UselessAssignment

pkgs.each do |pkg|
  package pkg do
    action :install
  end

  # Create /etc/default configuration
  template "/etc/default/#{pkg}" do
    source 'generic-env.sh.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables :options => {
      'metastore_port' => '9083',
      'hive_home' => "#{hadoop_lib_dir}/hive",
      'hcat_home' => "#{hadoop_lib_dir}/#{pkg}",
      'hadoop_home' => "#{hadoop_lib_dir}/hadoop",
      'hcat_pid_dir' => "/var/run/#{pkg}",
      'hcat_log_dir' => hcat_log_dir,
      'hive_ident_string' => 'hive',
      'hive_conf_dir' => '/etc/hive/conf',
      'hcat_conf_dir' => '/etc/hcatalog/conf'
    }
  end

  template "/etc/init.d/#{pkg}" do
    source 'hadoop-init.erb'
    mode '0755'
    owner 'root'
    group 'root'
    action :create
    variables :options => {
      'desc' => 'Hive HCatalog',
      'name' => pkg,
      'process' => 'java',
      'binary' => "#{hadoop_lib_dir}/#{pkg}/sbin/hcat_server.sh",
      'args' => '--config ${CONF_DIR} start',
      'confdir' => '${HCAT_CONF_DIR}',
      'user' => 'hive',
      'home' => "#{hadoop_lib_dir}/${pkg}",
      'pidfile' => "${HCAT_PID_DIR}/#{pkg}.pid",
      'logfile' => "${HCAT_LOG_DIR}/#{pkg}.log"
    }
  end

  service pkg do
    status_command "service #{pkg} status"
    supports [:restart => true, :reload => false, :status => true]
    action :nothing
  end

  # Update alternatives to point to our configuration
  execute 'update hcatalog-conf alternatives' do
    command "update-alternatives --install /etc/#{pkg}/conf hcatalog-conf /etc/#{pkg}/#{node['hcatalog']['conf_dir']} 50"
    not_if "update-alternatives --display hcatalog-conf | grep best | awk '{print $5}' | grep /etc/#{pkg}/#{node['hcatalog']['conf_dir']}"
  end
end

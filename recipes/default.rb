#
# Cookbook:: hadoop
# Recipe:: default
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
include_recipe 'hadoop::_hadoop_checkconfig'
include_recipe 'hadoop::_compression_libs'

package hadoop_package('hadoop-client') do
  action :install
end

libhdfs =
  if node['platform_family'] == 'debian'
    'libhdfs0'
  else
    hadoop_package('hadoop-libhdfs')
  end

package libhdfs do
  action :install
end

hadoop_conf_dir = "/etc/hadoop/#{node['hadoop']['conf_dir']}"

directory hadoop_conf_dir do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
end

# Setup capacity-scheduler.xml core-site.xml hadoop-policy.xml hdfs-site.xml mapred-site.xml yarn-site.xml
%w(capacity_scheduler core_site hadoop_policy hdfs_site mapred_site yarn_site).each do |sitefile|
  template "#{hadoop_conf_dir}/#{sitefile.tr('_', '-')}.xml" do
    source 'generic-site.xml.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables options: node['hadoop'][sitefile]
    only_if { node['hadoop'].key?(sitefile) && !node['hadoop'][sitefile].empty? }
  end
end # End capacity-scheduler.xml core-site.xml hadoop-policy.xml hdfs-site.xml mapred-site.xml yarn-site.xml

# Setup fair-scheduler.xml
fair_scheduler_file =
  if node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?('yarn.scheduler.fair.allocation.file')
    node['hadoop']['yarn_site']['yarn.scheduler.fair.allocation.file']
  else
    "#{hadoop_conf_dir}/fair-scheduler.xml"
  end

# This is a bit redundant, but necessary to pass foodcritic testing without duplicating resources
fair_scheduler_dir = File.dirname(fair_scheduler_file.gsub('file://', ''))
unless fair_scheduler_dir == hadoop_conf_dir
  directory fair_scheduler_dir do
    mode '0755'
    owner 'root'
    group 'root'
    action :create
    recursive true
    not_if { fair_scheduler_dir == hadoop_conf_dir }
  end
end

template fair_scheduler_file.gsub('file://', '') do
  source 'fair-scheduler.xml.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables node['hadoop']['fair_scheduler']
  only_if { node['hadoop'].key?('fair_scheduler') && !node['hadoop']['fair_scheduler'].empty? }
end # End fair-scheduler.xml

# Setup hadoop-env.sh mapred-env.sh yarn-env.sh
%w(hadoop_env mapred_env yarn_env).each do |envfile|
  %w(hadoop hadoop_mapred yarn).each do |svc|
    # Keep next here, in case envfile isn't set, so we don't NPE on directory resource
    next unless node['hadoop'].key?(envfile) && node['hadoop'][envfile].key?("#{svc}_log_dir")
    # Create directory
    directory node['hadoop'][envfile]["#{svc}_log_dir"] do
      log_dir_owner =
        if svc == 'hadoop_mapred'
          'mapred'
        elsif svc == 'hadoop'
          'hdfs'
        else
          svc
        end
      owner log_dir_owner
      group 'hadoop'
      mode '0775'
      action :create
      recursive true
    end
    log_dir =
      case svc
      when 'hadoop'
        'hdfs'
      when 'hadoop_mapred'
        'mapred'
      else
        svc
      end
    default_log_dir =
      if hdp22? && platform_family?('amazon', 'rhel')
        "/var/log/hadoop/#{log_dir}"
      else
        "/var/log/hadoop-#{log_dir}"
      end
    # Prevent duplicate resources
    # rubocop:disable Style/Next
    unless node['hadoop'][envfile]["#{svc}_log_dir"] == default_log_dir
      # Delete default directory, if we aren't set to it
      directory "/var/log/hadoop-#{log_dir}" do
        action :delete
        recursive true
        not_if "test -L /var/log/hadoop-#{log_dir}"
      end
      # HDP 2.2+ moves the default log directories
      directory "/var/log/hadoop/#{log_dir}" do
        action :delete
        recursive true
        not_if "test -L /var/log/hadoop/#{log_dir}"
      end
      # symlink default log directory
      link "/var/log/hadoop-#{log_dir}" do
        to node['hadoop'][envfile]["#{svc}_log_dir"]
      end
      # hdp 2.6.1 no longer creates /var/log/hadoop
      directory '/var/log/hadoop' do
        mode '0775'
        owner 'hdfs'
        group 'hadoop'
        action :create
        only_if { hdp22? && platform_family?('amazon', 'rhel') }
      end
      # symlink HDP 2.2 log directory
      link "/var/log/hadoop/#{log_dir}" do
        to node['hadoop'][envfile]["#{svc}_log_dir"]
        only_if { hdp22? && platform_family?('amazon', 'rhel') }
      end
    end
    # rubocop:enable Style/Next
  end

  # Evaluate any Delayed Interpolation tokens in *-env attributes
  delayed_attrs = { _FULL_VERSION: hdp_version }
  if node['hadoop'].key?(envfile) && !node['hadoop'][envfile].empty?
    node['hadoop'][envfile].each do |k, v|
      node.default['hadoop'][envfile][k] = v % delayed_attrs
    end
  end

  template "#{hadoop_conf_dir}/#{envfile.tr('_', '-')}.sh" do
    source 'generic-env.sh.erb'
    mode '0755'
    owner 'root'
    group 'root'
    action :create
    variables options: node['hadoop'][envfile]
    only_if { node['hadoop'].key?(envfile) && !node['hadoop'][envfile].empty? }
  end
end # End hadoop-env.sh yarn-env.sh

# Setup hadoop-metrics.properties hadoop-metrics2.properties log4j.properties
%w(hadoop_metrics hadoop_metrics2 log4j).each do |propfile|
  template "#{hadoop_conf_dir}/#{propfile.tr('_', '-')}.properties" do
    source 'generic.properties.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables properties: node['hadoop'][propfile]
    only_if { node['hadoop'].key?(propfile) && !node['hadoop'][propfile].empty? }
  end
end # End hadoop-metrics.properties hadoop-metrics2.properties log4j.properties

# Setup container-executor.cfg
template "#{hadoop_conf_dir}/container-executor.cfg" do
  source 'generic.properties.erb'
  mode '0400'
  owner 'root'
  group 'root'
  action :create
  variables properties: node['hadoop']['container_executor']
  only_if { node['hadoop'].key?('container_executor') && !node['hadoop']['container_executor'].empty? }
end # End container-executor.cfg

# Set hadoop.tmp.dir
hadoop_tmp_dir =
  if node['hadoop'].key?('core_site') && node['hadoop']['core_site'].key?('hadoop.tmp.dir')
    node['hadoop']['core_site']['hadoop.tmp.dir']
  else
    'file:///tmp/hadoop-${user}'
  end

node.default['hadoop']['core_site']['hadoop.tmp.dir'] = hadoop_tmp_dir

if node['hadoop']['core_site']['hadoop.tmp.dir'] == 'file:///tmp/hadoop-${user}'
  %w(hdfs mapreduce yarn).each do |dir|
    directory "/tmp/hadoop-#{dir}" do
      mode '1777'
      my_user =
        if dir == 'mapreduce'
          'mapred'
        else
          dir
        end
      owner my_user
      group my_user
      action :create
      recursive true
    end
  end
elsif node['hadoop']['core_site']['hadoop.tmp.dir'] =~ /${user}/
  # Since we're creating a 1777 directory, Hadoop can create the user-specific subdirectories, itself
  directory File.dirname(hadoop_tmp_dir.gsub('file://', '')) do
    mode '1777'
    action :create
    recursive true
  end
else
  directory hadoop_tmp_dir.gsub('file://', '') do
    mode '1777'
    action :create
    recursive true
  end
end # End hadoop.tmp.dir

jsvc_home =
  if node['hadoop']['distribution'] == 'hdp' && node['hadoop']['distribution_version'].to_f == 2.0 &&
     node['hadoop']['distribution_version'].to_s != '2' # Only '2' means latest 2.x release
    '/usr/libexec/bigtop-utils'
  else
    '/usr/lib/bigtop-utils'
  end

# Create /etc/default/hadoop
template '/etc/default/hadoop' do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'hadoop_home_warn_suppress' => true,
    'hadoop_home' => "#{hadoop_lib_dir}/hadoop",
    'hadoop_prefix' => "#{hadoop_lib_dir}/hadoop",
    'hadoop_libexec_dir' => "#{hadoop_lib_dir}/hadoop/libexec",
    'hadoop_conf_dir' => '/etc/hadoop/conf',
    'hadoop_common_home' => "#{hadoop_lib_dir}/hadoop",
    'hadoop_hdfs_home' => "#{hadoop_lib_dir}/hadoop-hdfs",
    'hadoop_mapred_home' => "#{hadoop_lib_dir}/hadoop-mapreduce",
    'hadoop_yarn_home' => "#{hadoop_lib_dir}/hadoop-yarn",
    'jsvc_home' => jsvc_home,
  }
end

# limits.d settings
%w(hdfs mapred yarn).each do |u|
  ulimit_domain u do
    node['hadoop']['limits'].each do |k, v|
      rule do
        item k
        type '-'
        value v
      end
    end
    only_if { node['hadoop'].key?('limits') && !node['hadoop']['limits'].empty? }
  end
end # End limits.d

# Remove extra mapreduce file, if it exists
file '/etc/security/limits.d/mapreduce.conf' do
  action :delete
end

# Another Hortonworks mess to clean up, their packages force-install blank configs here
directory '/etc/hadoop/conf' do
  action :delete
  recursive true
  not_if 'test -L /etc/hadoop/conf'
end

# Update alternatives to point to our configuration
execute 'update hadoop-conf alternatives' do
  command "update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/#{node['hadoop']['conf_dir']} 50"
  not_if "update-alternatives --display hadoop-conf | grep best | awk '{print $5}' | grep /etc/hadoop/#{node['hadoop']['conf_dir']}"
end

# Export hadoop environment variables
template '/etc/profile.d/hadoop.sh' do
  source 'generic-env.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  variables options: {
    'hadoop_conf_dir' => "/etc/hadoop/#{node['hadoop']['conf_dir']}",
    'yarn_conf_dir' => "/etc/hadoop/#{node['hadoop']['conf_dir']}",
  }
end

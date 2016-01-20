#
# Cookbook Name:: hadoop
# Recipe:: _sql_connectors
#
# Copyright © 2015 Cask Data, Inc.
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

pkgs = []
jars = []

# rubocop: disable Metrics/BlockNesting
if node['hadoop'].key?('sql_connector')
  case node['hadoop']['sql_connector']
  when 'mysql'
    if node['platform_family'] == 'rhel' && node['platform_version'].to_i == '5'
      Chef::Log.warn('You must download and install JDBC connectors, manually')
      pkgs = nil
    elsif node['platform_family'] == 'debian' && node['hadoop']['distribution'] != 'hdp'
      pkgs = ['libmysql-java']
      jars = ['mysql-connector-java']
    else
      pkgs = ['mysql-connector-java']
      jars = pkgs
    end
  when 'postgresql'
    if node['platform_family'] == 'rhel'
      if node['platform_version'].to_i == '5'
        Chef::Log.warn('You must download and install JDBC connectors, manually')
        pkgs = nil
      else
        pkgs = ['postgresql-jdbc']
      end
      jars = pkgs
    else # Assume debian
      pkgs = ['libpostgresql-jdbc-java']
      jars = ['postgresql-jdbc4']
    end
  ### TODO: Oracle support
  when 'oracle'
    Chef::Log.warn('You must download and install JDBC connectors, manually')
    pkgs = nil
    jars = pkgs
  else
    Chef::Log.info('No JDBC driver necessary')
  end
end
# rubocop: enable Metrics/BlockNesting

pkgs.each do |p|
  package p do
    action :install
  end
end

node.default['hadoop']['sql_jars'] = jars

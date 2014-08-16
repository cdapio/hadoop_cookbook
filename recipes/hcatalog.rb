#
# Cookbook Name:: hadoop
# Recipe:: hcatalog
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

include_recipe 'hadoop::hive'

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
  pkgs = %w(hcatalog)
  svcs = []
end
# rubocop:enable UselessAssignment

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

# Update alternatives to point to our configuration
# execute 'update hcatalog-conf alternatives' do
#  command "update-alternatives --install /etc/hcatalog/conf hcatalog-conf /etc/hcatalog/#{node['hcatalog']['conf_dir']} 50"
#  not_if "update-alternatives --display hcatalog-conf | grep best | awk '{print $5}' | grep /etc/hcatalog/#{node['hcatalog']['conf_dir']}"
# end

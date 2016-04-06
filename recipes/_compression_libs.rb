#
# Cookbook Name:: hadoop
# Recipe:: _compression_libs
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

pkgs = []

# Everybody gets snappy
case node['platform_family']
when 'debian'
  pkgs += ['libsnappy1', 'libsnappy-dev']
when 'rhel'
  pkgs += ['snappy', 'snappy-devel']
end

# HDP 2.2+ has lzo
if hdp22?
  case node['platform_family']
  when 'debian'
    pkgs += ['liblzo2-2', 'liblzo2-dev', 'hadooplzo']
  when 'rhel'
    pkgs += ['lzo', 'lzo-devel', 'hadooplzo', 'hadooplzo-native']
  end
end

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

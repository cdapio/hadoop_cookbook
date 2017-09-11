#
# Cookbook:: hadoop
# Recipe:: _compression_libs
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

pkgs = []

# Everybody gets snappy
case node['platform_family']
when 'debian'
  # HDP-UTILS repo provides its own libsnappy1, which conflicts with Ubuntu's libsnappy1v5
  pkgs += if node['platform_version'].to_i >= 16 && node['hadoop']['distribution'] != 'hdp'
            ['libsnappy1v5', 'libsnappy-dev']
          else
            ['libsnappy1', 'libsnappy-dev']
          end
when 'rhel', 'amazon'
  pkgs += ['snappy', 'snappy-devel']
end

# HDP 2.2+ has lzo
if hdp22?
  case node['platform_family']
  when 'debian'
    pkgs += ['liblzo2-2', 'liblzo2-dev', 'hadooplzo']
  when 'rhel', 'amazon'
    pkgs += ['lzo', 'lzo-devel', 'hadooplzo', 'hadooplzo-native']
  end
elsif iop?
  pkgs += ['lzo', 'lzo-devel', 'hadoop-lzo', 'hadoop-lzo-native']
end

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

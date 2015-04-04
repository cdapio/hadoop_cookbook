#
# Cookbook Name:: hadoop
# Recipe:: _system_tuning
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

include_recipe 'sysctl::default'
# Disable swapping
sysctl_param 'vm.swappiness' do
  value 0
end

case node['platform_family']
when 'debian', 'suse'
  thp_defrag = '/sys/kernel/mm/transparent_hugepage/defrag'
when 'rhel'
  thp_defrag = '/sys/kernel/mm/redhat_transparent_hugepage/defrag'
end

# Do not assume file exists, Ubuntu 14 in AWS does not have thp_defrag file
update_thp_defrag = true
file = File.new("#{thp_defrag}")
text = file.read
update_thp_defrag = false if ::File.exist?(thp_defrag) && text =~ /\[never\]/

execute 'disable-transparent-hugepage-compaction' do
  command "echo never > #{thp_defrag}"
  only_if { update_thp_defrag }
end

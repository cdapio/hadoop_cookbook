#
# Cookbook Name:: hadoop
# Recipe:: flume
#
# Copyright © 2013-2014 Continuuity, Inc.
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

pkg =
  if node['hadoop']['distribution'] == 'cdh'
    'flume-ng'
  else
    'flume'
  end

package pkg do
  action :install
end

flume_conf_dir = "/etc/flume/#{node['flume']['conf_dir']}"

directory flume_conf_dir do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  recursive true
end

# Setup flume.conf
if node['flume'].key? 'flume_conf'
  my_vars = { :options => node['flume']['flume_conf'] }

  template "#{flume_conf_dir}/flume.conf" do
    source 'generic.properties.erb'
    mode '0644'
    owner 'root'
    group 'root'
    action :create
    variables my_vars
  end
end # End flume.conf

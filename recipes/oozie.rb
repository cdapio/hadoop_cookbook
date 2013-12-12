#
# Cookbook Name:: hadoop
# Recipe:: oozie
#
# Copyright (C) 2013 Continuuity, Inc.
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
include_recipe 'hadoop::oozie_client'

package "oozie" do
  action :install
end

oozie_conf_dir = "/etc/oozie/#{node['oozie']['conf_dir']}"

directory oozie_conf_dir do
  mode "0755"
  owner "root"
  group "root"
  action :create
  recursive true
end

if node['oozie'].has_key? 'oozie_site'
  myVars = { :options => node['oozie']['oozie_site'] }

  template "#{oozie_conf_dir}/oozie-site.xml" do
    source "generic-site.xml.erb"
    mode "0644"
    owner "oozie"
    group "oozie"
    action :create
    variables myVars
  end
end

service "oozie" do
  action :nothing
end

# Update alternatives to point to our configuration
execute "update oozie-conf alternatives" do
  command "update-alternatives --install /etc/oozie/conf oozie-conf /etc/oozie/#{node['oozie']['conf_dir']} 50"
  not_if "update-alternatives --display oozie-conf | grep best | awk '{print $5}' | grep /etc/oozie/#{node['oozie']['conf_dir']}"
end

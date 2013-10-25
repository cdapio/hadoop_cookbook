#
# Cookbook Name:: hadoop
# Recipe:: default
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

package "hadoop-client" do
  action :install
end

hadoop_conf_dir = "/etc/hadoop/#{node[:hadoop][:conf_dir]}"

directory hadoop_conf_dir do
  mode 0755
  owner "root"
  group "root"
  action :create
  recursive true
end

execute "update hadoop-conf alternatives" do
  command "update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/#{node[:hadoop][:conf_dir]} 50"
  not_if "update-alternatives --query hadoop-conf | grep Best | cut -d' ' -f2- | grep /etc/hadoop/#{node[:hadoop][:conf_dir]}"
end

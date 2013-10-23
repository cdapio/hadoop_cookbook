#
# Cookbook Name:: hadoop
# Recipe:: repo
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

major_platform_version = node['platform_version'].to_i

case node['hadoop']['distribution']
when 'hdp'
  # We only support HDP 2.0 (2.0.6.0) at this time
  hdp_version = "2.0.6.0"
  # HDP only supports platform_family = rhel
  case node['platform_family']
  when 'rhel'
    yum_base_url = 'http://public-repo-1.hortonworks.com/HDP'
    os = "centos#{major_platform_version}"
    key = "RPM-GPG-KEY"
    yum_repo_key = node['hadoop']['yum_repo_key'] ? node['hadoop']['yum_repo_key'] : "#{yum_base_url}/#{os}/#{key}/#{key}-Jenkins"
    yum_repo_url = node['hadoop']['yum_repo_url'] ? node['hadoop']['yum_repo_url'] : "#{yum_base_url}/#{os}/2.x/GA"

    yum_key "#{key}-HDP" do
      url yum_repo_key
      action :add
    end
    yum_repository "hdp" do
      name "HDP-2.x"
      description "Hortonworks Data Platform Version - HDP-2.x"
      url yum_repo_url
      key "#{key}-HDP"
      action :add
    end
    yum_repository "hdp-updates" do
      name "Updates-HDP-2.x"
      description "Updates for Hortonworks Data Platform Version - HDP-2.x"
      url "#{yum_base_url}/#{os}/2.x/updates/#{hdp_version}"
      key "#{key}-HDP"
      action :add
    end
  else
    Chef::Application.fatal!("Hortonworks currently only supports node['platform_family'] = rhel")
  end
end

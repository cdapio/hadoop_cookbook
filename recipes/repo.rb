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
key = "RPM-GPG-KEY"

# Ensure that we have the proper LWRPs available
case node['platform_family']
when 'rhel'
  include_recipe 'yum'
when 'debian'
  include_recipe 'apt'
end

case node['hadoop']['distribution']
when 'hdp'
  # We only support HDP 2.0 (2.0.6.0) at this time
  hdp_version = "2.0.6.0"
  hdp_utils_version = "1.1.0.16"
  case node['platform_family']
  when 'rhel'
    yum_base_url = 'http://public-repo-1.hortonworks.com/HDP'
    os = "centos#{major_platform_version}"
    yum_repo_url = node['hadoop']['yum_repo_url'] ? node['hadoop']['yum_repo_url'] : "#{yum_base_url}/#{os}/2.x/GA"
    yum_repo_key_url = node['hadoop']['yum_repo_key_url'] ? node['hadoop']['yum_repo_key_url'] : "#{yum_base_url}/#{os}/#{key}/#{key}-Jenkins"

    yum_key "#{key}-HDP" do
      url yum_repo_key_url
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
    yum_repository "hdp-utils" do
      name "HDP-UTILS-#{hdp_utils_version}"
      description "Hortonworks Data Platform Utils Version - HDP-UTILS-#{hdp_utils_version}"
      url "#{yum_base_url}-UTILS-#{hdp_utils_version}/repos/#{os}"
      key "#{key}-HDP"
      action :add
    end

  when 'debian'
    apt_base_url = 'http://public-repo-1.hortonworks.com/HDP'
    os = "ubuntu#{major_platform_version}"
    apt_repo_url = node['hadoop']['apt_repo_url'] ? node['hadoop']['apt_repo_url'] : "#{apt_base_url}/#{os}/2.x"
    # Hortonworks don't know how to provide a key, but we do
    apt_repo_key_url = node['hadoop']['apt_repo_key_url'] ? node['hadoop']['apt_repo_key_url'] : "#{apt_base_url}/centos6/#{key}/#{key}-Jenkins"

    apt_repository "hdp" do
      uri apt_repo_url
      key apt_repo_key_url
      distribution "HDP"
      components [ "main" ]
      action :add
    end
    apt_repository "hdp-utils" do
      uri "#{apt_base_url}-UTILS-#{hdp_utils_version}/repos/#{os}"
      key apt_repo_key_url
      distribution "HDP-UTILS"
      components [ "main" ]
      action :add
    end
  end # End hdp

when 'cdh'
  cdh_release = node['hadoop']['distribution_version'].to_i
  case node['platform_family']
  when 'rhel'
    yum_base_url = "http://archive.cloudera.com/cdh#{cdh_release}/redhat"
    yum_repo_url = node['hadoop']['yum_repo_url'] ? node['hadoop']['yum_repo_url'] : "#{yum_base_url}/#{major_platform_version}/#{node['kernel']['machine']}/cdh/#{node['hadoop']['distribution_version']}"
    yum_repo_key_url = node['hadoop']['yum_repo_key_url'] ? node['hadoop']['yum_repo_key_url'] : "#{yum_base_url}/#{major_platform_version}/#{node['kernel']['machine']}/cdh/#{key}-cloudera"

    yum_key "#{key}-cloudera" do
      url yum_repo_key_url
      action :add
    end
    yum_repository "cloudera-cdh#{cdh_release}" do
      name "cloudera-cdh#{cdh_release}"
      description "Cloudera's Distribution for Hadoop, Version #{cdh_release}"
      url yum_repo_url
      key "#{key}-cloudera"
      action :add
    end

  when 'debian'
    codename = node['lsb']['codename']
    apt_base_url = "http://archive.cloudera.com/cdh#{cdh_release}/#{node['platform']}"
    apt_repo_url = node['hadoop']['apt_repo_url'] ? node['hadoop']['apt_repo_url'] : "#{apt_base_url}/#{codename}/amd64/cdh"
    apt_repo_key_url = node['hadoop']['apt_repo_key_url'] ? node['hadoop']['apt_repo_key_url'] : "#{apt_base_url}/#{codename}/amd64/cdh/archive.key"

    apt_repository "cloudera-cdh#{cdh_release}" do
      uri apt_repo_url
      key apt_repo_key_url
      distribution "#{codename}-cdh#{node['hadoop']['distribution_version']}"
      components [ "contrib" ]
      arch "amd64"
      action :add
    end
  end # End cdh
end

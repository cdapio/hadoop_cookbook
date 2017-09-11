#
# Cookbook:: hadoop
# Recipe:: repo
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

major_platform_version = node['platform_version'].to_i
key = 'RPM-GPG-KEY'

# Ensure apt caches are updated and apt resources available
include_recipe 'apt' if node['platform_family'] == 'debian'

case node['hadoop']['distribution']
when 'hdp'
  case node['hadoop']['distribution_version']
  when '2.0.5.0', '2.0.6.0', '2.0.6.1', '2.0.10.0', '2.0.11.0', '2.0.12.0', '2.0.13.0'
    hdp_version = '2.0.4.0'
    hdp_update_version = node['hadoop']['distribution_version']
  when '2.0'
    hdp_version = '2.0.4.0'
    hdp_update_version = '2.0.13.0'
    Chef::Log.warn("Short versions for node['hadoop']['distribution_version'] are deprecated! Please use full version!")
    node.override['hadoop']['distribution_version'] = hdp_update_version
  when '2.0.4.0', '2.1.1.0', '2.2.0.0'
    hdp_version = node['hadoop']['distribution_version']
    hdp_update_version = nil
  when '2.1.2.0', '2.1.2.1', '2.1.3.0', '2.1.4.0', '2.1.5.0', '2.1.7.0', '2.1.10.0', '2.1.15.0'
    hdp_version = '2.1.1.0'
    hdp_update_version = node['hadoop']['distribution_version']
  when '2.1'
    hdp_version = '2.1.1.0'
    hdp_update_version = '2.1.15.0'
    Chef::Log.warn("Short versions for node['hadoop']['distribution_version'] are deprecated! Please use full version!")
    node.override['hadoop']['distribution_version'] = hdp_update_version
  # 2.3, 2.4, and 2.5 do not have their own base version
  when '2.2.1.0', '2.2.4.2', '2.2.4.4', '2.2.6.0', '2.2.6.3', '2.2.8.0', '2.2.9.0',
       '2.3.0.0', '2.3.2.0', '2.3.4.0', '2.3.4.7', '2.3.6.0',
       '2.4.0.0', '2.4.2.0', '2.4.3.0',
       '2.5.0.0', '2.5.3.0', '2.5.5.0',
       '2.6.0.3', '2.6.1.0'
    hdp_version = '2.2.0.0'
    hdp_update_version = node['hadoop']['distribution_version']
  when '2.2'
    hdp_version = '2.2.0.0'
    hdp_update_version = '2.2.9.0'
    Chef::Log.warn("Short versions for node['hadoop']['distribution_version'] are deprecated! Please use full version!")
    node.override['hadoop']['distribution_version'] = hdp_update_version
  when '2.3'
    hdp_version = '2.2.0.0'
    hdp_update_version = '2.3.6.0'
    Chef::Log.warn("Short versions for node['hadoop']['distribution_version'] are deprecated! Please use full version!")
    node.override['hadoop']['distribution_version'] = hdp_update_version
  when '2.4'
    hdp_version = '2.2.0.0'
    hdp_update_version = '2.4.3.0'
    Chef::Log.warn("Short versions for node['hadoop']['distribution_version'] are deprecated! Please use full version!")
    node.override['hadoop']['distribution_version'] = hdp_update_version
  when '2.5'
    hdp_version = '2.2.0.0'
    hdp_update_version = '2.5.5.0'
    Chef::Log.warn("Short versions for node['hadoop']['distribution_version'] are deprecated! Please use full version!")
    node.override['hadoop']['distribution_version'] = hdp_update_version
  when '2.6', '2'
    hdp_version = '2.2.0.0'
    hdp_update_version = '2.6.1.0'
    Chef::Log.warn("Short versions for node['hadoop']['distribution_version'] are deprecated! Please use full version!")
    node.override['hadoop']['distribution_version'] = hdp_update_version
  else
    Chef::Application.fatal!('This cookbook only supports HDP 2.x')
  end

  hdp_utils_version = '1.1.0.21'

  case node['platform_family']
  when 'rhel', 'amazon'
    yum_base_url = 'http://public-repo-1.hortonworks.com/HDP'
    os = if major_platform_version == 5 || hdp_version.to_f >= 2.3
           "centos#{major_platform_version}"
         else
           'centos6'
         end

    yum_repo_url = node['hadoop']['yum_repo_url'] ? node['hadoop']['yum_repo_url'] : "#{yum_base_url}/#{os}/2.x/GA/#{hdp_version}"
    yum_repo_key_url = node['hadoop']['yum_repo_key_url'] ? node['hadoop']['yum_repo_key_url'] : "#{yum_base_url}/#{os}/#{key}/#{key}-Jenkins"

    yum_repository 'hdp' do
      name 'HDP-2.x'
      description 'Hortonworks Data Platform Version - HDP-2.x'
      url yum_repo_url
      gpgkey yum_repo_key_url
      action :add
    end
    if hdp_update_version.nil?
      yum_repository 'hdp-updates' do
        name 'Updates-HDP-2.x'
        description 'Updates for Hortonworks Data Platform Version - HDP-2.x'
        url "#{yum_base_url}/#{os}/2.x/updates"
        gpgkey yum_repo_key_url
        action :add
      end
    else
      yum_repository 'hdp-updates' do
        name 'Updates-HDP-2.x'
        description 'Updates for Hortonworks Data Platform Version - HDP-2.x'
        url "#{yum_base_url}/#{os}/2.x/updates/#{hdp_update_version}"
        gpgkey yum_repo_key_url
        action :add
      end
    end
    yum_repository 'hdp-utils' do
      name "HDP-UTILS-#{hdp_utils_version}"
      description "Hortonworks Data Platform Utils Version - HDP-UTILS-#{hdp_utils_version}"
      url "#{yum_base_url}-UTILS-#{hdp_utils_version}/repos/#{os}"
      gpgkey yum_repo_key_url
      action :add
    end

  when 'debian'
    apt_domain_name = 'public-repo-1.hortonworks.com'
    apt_base_url = "http://#{apt_domain_name}/HDP"
    hdp_update_version = hdp_version if hdp_update_version.nil?
    # HDP supports Debian 6, Ubuntu 12. Starting with 2.3.2.0 Ubuntu 14 and Debian 7
    if node['platform'] == 'debian' && node['platform_version'] =~ /^7/ && Gem::Version.new(hdp_update_version) >= Gem::Version.new('2.3.2.0')
      os = "#{node['platform']}7"
    elsif node['platform'] == 'debian'
      os = "#{node['platform']}6"
    elsif node['platform'] == 'ubuntu' && node['platform_version'] =~ /^14/ && Gem::Version.new(hdp_update_version) >= Gem::Version.new('2.3.2.0')
      os = "#{node['platform']}14"
    elsif node['platform'] == 'ubuntu'
      os = "#{node['platform']}12"
    end
    hdp_apt_repo_path =
      case hdp_update_version
      when '2.2.0.0'
        "2.x/GA/#{hdp_update_version}"
      when '2.1.10.0', '2.1.15.0', '2.2.1.0', '2.2.4.2', '2.2.6.0', '2.2.6.3', '2.2.8.0', '2.2.9.0',
           '2.3.0.0', '2.3.2.0', '2.3.4.0', '2.3.4.7', '2.3.6.0',
           '2.4.0.0', '2.4.2.0', '2.4.3.0',
           '2.5.0.0', '2.5.3.0', '2.5.5.0',
           '2.6.0.3', '2.6.1.0'
        "2.x/updates/#{hdp_update_version}"
      else
        hdp_update_version
      end
    apt_repo_url = node['hadoop']['apt_repo_url'] ? node['hadoop']['apt_repo_url'] : "#{apt_base_url}/#{os}/#{hdp_apt_repo_path}"
    # Hortonworks don't know how to provide a key, but we do
    apt_repo_key_url = node['hadoop']['apt_repo_key_url'] ? node['hadoop']['apt_repo_key_url'] : "#{apt_base_url}/centos6/#{key}/#{key}-Jenkins"

    apt_repository 'hdp' do
      uri apt_repo_url
      key apt_repo_key_url
      distribution 'HDP'
      trusted true
      components ['main']
      action :add
    end
    apt_repository 'hdp-utils' do
      uri "#{apt_base_url}-UTILS-#{hdp_utils_version}/repos/#{os}"
      key apt_repo_key_url
      distribution 'HDP-UTILS'
      components ['main']
      action :add
    end
    apt_preference 'hdp' do
      glob '*'
      pin "origin #{apt_domain_name}"
      pin_priority '700'
    end
  end # End hdp

when 'cdh'
  cdh_release = node['hadoop']['distribution_version'].to_i
  if node['hadoop']['distribution_version'].to_f >= 5.3 && node.key?('java') && node['java'].key?('jdk_version') && node['java']['jdk_version'].to_i < 7
    Chef::Application.fatal!('CDH 5.3 and above require Java 7 or higher')
  end
  Chef::Log.warn("Short versions for node['hadoop']['distribution_version'] are deprecated! Please use full version!") if node['hadoop']['distribution_version'].to_s == '5'
  case node['platform_family']
  when 'rhel', 'amazon'
    yum_base_url = "http://archive.cloudera.com/cdh#{cdh_release}/redhat"
    yum_repo_url = node['hadoop']['yum_repo_url'] ? node['hadoop']['yum_repo_url'] : "#{yum_base_url}/#{major_platform_version}/#{node['kernel']['machine']}/cdh/#{node['hadoop']['distribution_version']}"
    yum_repo_key_url = node['hadoop']['yum_repo_key_url'] ? node['hadoop']['yum_repo_key_url'] : "#{yum_base_url}/#{major_platform_version}/#{node['kernel']['machine']}/cdh/#{key}-cloudera"

    yum_repository "cloudera-cdh#{cdh_release}" do
      name "cloudera-cdh#{cdh_release}"
      description "Cloudera's Distribution for Hadoop, Version #{cdh_release}"
      url yum_repo_url
      gpgkey yum_repo_key_url
      action :add
    end

  when 'debian'
    codename = node['lsb']['codename']

    # rubocop: disable Metrics/BlockNesting
    case codename
    when 'raring', 'saucy'
      Chef::Log.warn('This version of Ubuntu is unsupported by Cloudera! Bug reports should include patches.')
      codename = 'precise'
    when 'trusty'
      unless cdh_release >= 5
        Chef::Log.warn('This version of Ubuntu is unsupported by Cloudera! Bug reports should include patches.')
        codename = 'precise'
      end
    end
    # rubocop: enable Metrics/BlockNesting

    apt_domain_name = 'archive.cloudera.com'
    apt_base_url = "http://#{apt_domain_name}/cdh#{cdh_release}/#{node['platform']}"
    apt_repo_url = node['hadoop']['apt_repo_url'] ? node['hadoop']['apt_repo_url'] : "#{apt_base_url}/#{codename}/amd64/cdh"
    apt_repo_key_url = node['hadoop']['apt_repo_key_url'] ? node['hadoop']['apt_repo_key_url'] : "#{apt_base_url}/#{codename}/amd64/cdh/archive.key"

    apt_repository "cloudera-cdh#{cdh_release}" do
      uri apt_repo_url
      key apt_repo_key_url
      distribution "#{codename}-cdh#{node['hadoop']['distribution_version']}"
      components ['contrib']
      arch 'amd64'
      action :add
    end

    apt_preference "cloudera-cdh#{cdh_release}" do
      glob '*'
      pin "origin #{apt_domain_name}"
      pin_priority '700'
    end
  end # End cdh

when 'bigtop'
  bigtop_release = node['hadoop']['distribution_version']

  # allow a developer mode for use when developing against bigtop, see https://issues.cask.co/browse/COOK-1
  if bigtop_release.casecmp('develop').zero? && !(node['hadoop'].key?('yum_repo_url') || node['hadoop'].key?('apt_repo_url'))
    Chef::Application.fatal!("You must set node['hadoop']['yum_repo_url'] or node['hadoop']['apt_repo_url'] when specifying node['hadoop']['distribution_version'] == 'develop'")
  end

  # do not validate gpg repo keys when in develop mode
  validate_repo_key = bigtop_release.casecmp('develop').zero? ? false : true
  Chef::Log.warn('Allowing install of unsigned binaries') unless validate_repo_key

  case node['platform_family']
  when 'rhel', 'amazon'

    case major_platform_version
    when 5, 6
      yum_platform_version = major_platform_version
    when 2014, 2015, 2016 # Amazon Linux, point to redhat/6 bigtop repo
      yum_platform_version = 6
    else
      Chef::Log.warn('Unsupported platform detected, use at your own risk')
      yum_platform_version = major_platform_version
    end

    yum_base_url = "http://bigtop-repos.s3.amazonaws.com/releases/#{bigtop_release}/centos"
    yum_repo_url = node['hadoop']['yum_repo_url'] ? node['hadoop']['yum_repo_url'] : "#{yum_base_url}/#{yum_platform_version}/#{node['kernel']['machine']}"
    yum_repo_key_url = node['hadoop']['yum_repo_key_url'] ? node['hadoop']['yum_repo_key_url'] : 'http://archive.apache.org/dist/bigtop/KEYS'

    yum_repository "bigtop-#{bigtop_release}" do
      name "bigtop-#{bigtop_release}"
      description "Apache Bigtop Distribution for Hadoop, Version #{bigtop_release}"
      url yum_repo_url
      gpgkey yum_repo_key_url
      gpgcheck validate_repo_key
      action :add
    end

  when 'debian'
    # for bigtop, we do not validate codename, to support developing against custom repositories
    codename = node['lsb']['codename']

    # rubocop: disable Metrics/BlockNesting
    case codename
    when 'precise', 'quantal', 'raring', 'saucy', 'utopic', 'vivid', 'wily'
      if bigtop_release.to_f >= 1.0
        Chef::Log.warn('This version of Ubuntu is unsupported by Bigtop! Bug reports should include patches.')
        codename = 'trusty'
      end
    end
    # rubocop: enable Metrics/BlockNesting

    apt_domain_name = 'bigtop-repos.s3.amazonaws.com'
    apt_base_url = "http://#{apt_domain_name}/releases/#{bigtop_release}/#{node['platform']}"
    apt_repo_url = node['hadoop']['apt_repo_url'] ? node['hadoop']['apt_repo_url'] : "#{apt_base_url}/#{codename}/#{node['kernel']['machine']}"
    apt_repo_key_url = node['hadoop']['apt_repo_key_url'] ? node['hadoop']['apt_repo_key_url'] : 'http://archive.apache.org/dist/bigtop/KEYS'

    apt_repository "bigtop-#{bigtop_release}" do
      uri apt_repo_url
      key apt_repo_key_url
      trusted !validate_repo_key
      distribution 'bigtop'
      components ['contrib']
      action :add
    end
    apt_preference "bigtop-#{bigtop_release}" do
      glob '*'
      pin "origin #{apt_domain_name}"
      pin_priority '700'
    end
  end

when 'iop'
  iop_version = node['hadoop']['distribution_version']
  iop_release = "#{node['hadoop']['distribution_version'].to_f}.x"
  iop_utils_version = '1.2.0.0'

  case node['platform_family']
  when 'rhel', 'amazon'
    # https://ibm-open-platform.ibm.com/repos/IOP/rhel/6/x86_64/4.1.x/GA/4.1.0.0/
    yum_base_url = 'https://ibm-open-platform.ibm.com/repos/IOP'
    os = 'rhel'
    v = major_platform_version
    m = node['kernel']['machine']
    key = 'BI-GPG-KEY.public'

    yum_repo_url = node['hadoop']['yum_repo_url'] ? node['hadoop']['yum_repo_url'] : "#{yum_base_url}/#{os}/#{v}/#{m}/#{iop_release}/GA/#{iop_version}"
    yum_repo_key_url = node['hadoop']['yum_repo_key_url'] ? node['hadoop']['yum_repo_key_url'] : "#{yum_repo_url}/#{key}"

    yum_repository 'iop' do
      name "IOP-#{iop_release}"
      description "IBM Open Platform Version - IOP-#{iop_release}"
      url yum_repo_url
      gpgkey yum_repo_key_url
      action :add
    end
    yum_repository 'iop-utils' do
      name "IOP-UTILS-#{iop_utils_version}"
      description "IBM Open Platform Utils Version - IOP-UTILS-#{iop_utils_version}"
      url "#{yum_base_url}-UTILS/#{os}/#{v}/#{m}/#{iop_utils_version.to_f}"
      gpgkey yum_repo_key_url
      # disable gpgcheck because the Hadoop-lzo package is unsigned
      gpgcheck false
      action :add
    end
  else
    Chef::Application.fatal!("IBM Open Platform only supports RHEL-family! You're on #{node['platform_family']}!")
  end

else
  # COOK-25 fail fast
  Chef::Application.fatal!("Invalid node['hadoop']['distribution'] (#{node['hadoop']['distribution']}) specified!")
end

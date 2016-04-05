#
# Cookbook Name:: hadoop
# Library:: helpers
#
# Copyright © 2015 Cask Data, Inc.
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

module Hadoop
  module Helpers
    #
    # Disable service auto-start on Debian-based platforms
    #
    def policy_rcd(cmd)
      case cmd
      when 'disable'
        Chef::Log.info('Disabling package auto-start')
        ::File.open('/usr/sbin/policy-rc.d', 'w', 0755) { |f| f.write('exit 101') }
      when 'enable'
        Chef::Log.info('Enabling package auto-start')
        ::File.delete('/usr/sbin/policy-rc.d') if ::File.exist?('/usr/sbin/policy-rc.d')
      else
        Chef::Application.fatal!('The policy_rc.d method only accepts "disable" or "enable" as arguments')
      end
    end

    #
    # Return HDP 2.2 version, including revision, used for building HDP 2.2+ on-disk paths
    #
    def hdp_version
      case node['hadoop']['distribution_version']
      when '2.2.0.0'
        '2.2.0.0-2041'
      when '2.2.1.0'
        '2.2.1.0-2340'
      when '2.2.4.2'
        '2.2.4.2-2'
      when '2.2.4.4'
        '2.2.4.4-16'
      when '2.2.6.0'
        '2.2.6.0-2800'
      when '2.2.6.3'
        '2.2.6.3-1'
      when '2.2.8.0'
        '2.2.8.0-3150'
      when '2.2.9.0'
        '2.2.9.0-3393'
      when '2.3.0.0'
        '2.3.0.0-2557'
      when '2.3.2.0'
        '2.3.2.0-2950'
      when '2.3.4.0'
        '2.3.4.0-3485'
      when '2.3.4.7'
        '2.3.4.7-4'
      when '2.4.0.0'
        '2.4.0.0-169'
      else
        node['hadoop']['distribution_version']
      end
    end

    #
    # Return true if HDP 2.2+
    #
    def hdp22?
      node['hadoop']['distribution'] == 'hdp' && node['hadoop']['distribution_version'].to_f >= 2.2
    end

    #
    # Return correct package name on ODP-based distributions
    #
    # Given name: hadoop-mapreduce-historyserver
    # ODP name: hadoop_2_4_0_0_169-mapreduce-historyserver
    #
    def hadoop_package(name)
      return name unless hdp22?
      return name if node['platform_family'] == 'debian'
      fw = name.split('-').first
      pv = hdp_version.tr('.', '_').tr('-', '_')
      nn = "#{fw}_#{pv}"
      name.gsub(fw, nn)
    end

    #
    # Return true if Kerberos is enabled
    #
    # rubocop: disable Metrics/AbcSize
    def hadoop_kerberos?
      node['hadoop']['core_site'].key?('hadoop.security.authorization') &&
        node['hadoop']['core_site'].key?('hadoop.security.authentication') &&
        node['hadoop']['core_site']['hadoop.security.authorization'].to_s == 'true' &&
        node['hadoop']['core_site']['hadoop.security.authentication'] == 'kerberos'
    end
    # rubocop: enable Metrics/AbcSize

    #
    # Return parent directory for various Hadoop lib directories and homes
    #
    def hadoop_lib_dir
      if hdp22?
        "/usr/hdp/#{hdp_version}"
      else
        '/usr/lib'
      end
    end
  end
end

# Load helpers
Chef::Recipe.send(:include, Hadoop::Helpers)
Chef::Resource.send(:include, Hadoop::Helpers)

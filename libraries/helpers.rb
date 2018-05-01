#
# Cookbook:: hadoop
# Library:: helpers
#
# Copyright © 2015-2018 Cask Data, Inc.
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

require 'net/http'

module Hadoop
  module Helpers
    #
    # Given an HDP version (2.6.1.0), return its build number (129)
    #
    def hdp_build_number(version)
      repo_path = [
        'http://public-repo-1.hortonworks.com/HDP',
        hdp_repo_os_path,
        '2.x/updates',
        version,
        'build.id',
      ]
      build_id_url = File.join(repo_path)

      uri = URI.parse(build_id_url)
      req = Net::HTTP::Get.new(uri.path)

      response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req)
      end

      case response.code
      when '200'
        build_h = Hash[response.body.split("\n").map { |str| str.split(': ') }]
        build_h['BUILD_NUMBER'] if build_h.key?('BUILD_NUMBER')
      end
    rescue StandardError
      nil
    end

    #
    # Returns the HDP Repo path component for this OS, ie centos7, ubuntu14
    #
    def hdp_repo_os_path
      value_for_platform_family(
        %w(rhel amazon) => "centos#{node['platform_version'].to_i}",
        'debian' => "#{node['platform']}#{node['platform_version'].to_i}"
      )
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
      when '2.3.6.0'
        '2.3.6.0-3796'
      when '2.4.0.0'
        '2.4.0.0-169'
      when '2.4.2.0'
        '2.4.2.0-258'
      when '2.4.3.0'
        '2.4.3.0-227'
      when '2.5.0.0'
        '2.5.0.0-1245'
      when '2.5.3.0'
        '2.5.3.0-37'
      when '2.5.5.0'
        '2.5.5.0-157'
      when '2.5.6.0'
        '2.5.6.0-40'
      when '2.6.0.3'
        '2.6.0.3-8'
      when '2.6.1.0'
        '2.6.1.0-129'
      when '2.6.2.0'
        '2.6.2.0-205'
      when '2.6.3.0'
        '2.6.3.0-235'
      when '2.6.4.0'
        '2.6.4.0-91'
      else
        # fetch build number from HDP public repository
        build_number = hdp_build_number(node['hadoop']['distribution_version'])
        [node['hadoop']['distribution_version'], build_number].compact.join('-')
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
      return name unless hdp22? || iop?
      return name if node['platform_family'] == 'debian'
      fw =
        if name == 'spark-core'
          name
        else
          name.split('-').first
        end
      pv =
        if hdp22?
          hdp_version.tr('.', '_').tr('-', '_')
        else
          node['hadoop']['distribution_version'].tr('.', '_')
        end
      nn = "#{fw}_#{pv}"
      name.gsub(fw, nn)
    end

    # Return true if IOP
    #
    def iop?
      node['hadoop']['distribution'] == 'iop'
    end

    #
    # Return true if Kerberos is enabled
    #
    def hadoop_kerberos?
      node['hadoop']['core_site'].key?('hadoop.security.authorization') &&
        node['hadoop']['core_site'].key?('hadoop.security.authentication') &&
        node['hadoop']['core_site']['hadoop.security.authorization'].to_s == 'true' &&
        node['hadoop']['core_site']['hadoop.security.authentication'] == 'kerberos'
    end

    #
    # Return parent directory for various Hadoop lib directories and homes
    #
    def hadoop_lib_dir
      if hdp22?
        "/usr/hdp/#{hdp_version}"
      elsif iop?
        "/usr/iop/#{node['hadoop']['distribution_version']}"
      else
        '/usr/lib'
      end
    end

    #
    # Return Hadoop configuration item value using deprecated properties or a specified default
    #
    def hadoop_config(service, key, property, deprecated_property = nil, default_value = nil)
      if node.key?(service) && node[service].key?(key) && node[service][key].key?(property)
        node[service][key][property]
      elsif node.key?(service) && node[service].key?(key) && node[service][key].key?(deprecated_property)
        node[service][key][deprecated_property]
      else
        default_value
      end
    end

    #
    # Check for deprecated JAAS configuration
    #
    def check_deprecated_jaas_config(service)
      if node[service].key?('jaas')
        %w(client server).each do |key|
          next unless node[service]['jaas'].key?(key) &&
                      node[service]['jaas'][key].key?('usekeytab') &&
                      node[service]['jaas'][key]['usekeytab'].to_s == 'true'
          next unless node[service]['jaas'][key]['keytab'].nil? ||
                      node['hbase']['jaas'][key]['principal'].nil?
          Chef::Application.fatal!("You must set node['#{service}']['jaas']['#{key}']['keytab'] and node['#{service}']['jaas']['#{key}']['principal'] with node['#{service}']['jaas'][key]['usekeytab']")
        end
      end
      Chef::Log.warn("Using node['#{service}']['jaas'] is deprecated. Use node['#{service}']['client_jaas'] and node['#{service}']['master_jaas'], instead") if node[service].key?('jaas')
    end

    #
    # Check for JAAS configuration
    #
    def check_jaas_config(service)
      %w(client master).each do |type|
        next unless node[service].key?("#{type}_jaas")
        %w(client server).each do |key| # These are JAAS keys, not files
          next unless node[service]["#{type}_jaas"].key?(key) &&
                      node[service]["#{type}_jaas"][key].key?('usekeytab') &&
                      node[service]["#{type}_jaas"][key]['usekeytab'].to_s == 'true'
          next unless node[service]["#{type}_jaas"][key]['keytab'].nil? ||
                      node[service]["#{type}_jaas"][key]['principal'].nil?
          Chef::Application.fatal!("You must set node['#{service}']['#{type}_jaas']['#{key}']['keytab'] and node['#{service}']['#{type}_jaas']['#{key}']['principal'] with node['#{service}']['#{type}_jaas'][key]['usekeytab']")
        end
      end
    end

    #
    # Write deprecated JAAS configuration
    #
    def write_deprecated_jaas_config(service)
      return unless node[service].key?('jaas') &&
                    node[service]['jaas'].key?('client')
      conf_dir = "/etc/#{service}/#{node[service]['conf_dir']}"
      template "#{conf_dir}/jaas.conf" do
        source 'jaas.conf.erb'
        mode '0644'
        owner 'root'
        group 'root'
        action :create
        variables(
          client: node[service]['jaas']['client'],
          server: node[service]['jaas']['server'] || nil
        )
      end
    end

    #
    # Write JAAS configuration
    #
    def write_jaas_config(service)
      # Setup client_jaas.conf master_jaas.conf
      %w(client master).each do |type|
        next unless node[service].key?("#{type}_jaas") &&
                    node[service]["#{type}_jaas"].key?('client')
        conf_dir = "/etc/#{service}/#{node[service]['conf_dir']}"
        template "#{conf_dir}/#{type}_jaas.conf" do
          source 'jaas.conf.erb'
          mode '0644'
          owner service
          group service
          action :create
          variables(
            client: node[service]["#{type}_jaas"]['client'],
            server: node[service]["#{type}_jaas"]['server'] || nil
          )
        end
      end
    end
  end
end

# Load helpers
Chef::Recipe.send(:include, Hadoop::Helpers)
Chef::Resource.send(:include, Hadoop::Helpers)

require 'spec_helper'

describe 'hadoop::zookeeper' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.3.4.7'
        node.default['zookeeper']['jaas']['client']['foo'] = 'bar'
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'install zookeeper package' do
      expect(chef_run).to install_package('zookeeper_2_3_4_7_4')
    end

    it 'creates /etc/zookeeper/conf.chef/jaas.conf from template' do
      expect(chef_run).to create_template('/etc/zookeeper/conf.chef/jaas.conf')
    end
  end

  context 'on HDP 2.1' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.1.15.0'
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'install zookeeper package' do
      expect(chef_run).to install_package('zookeeper')
    end
  end

  context 'on Ubuntu 12.04 on CDH 5.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 12.04) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
        node.default['hadoop']['distribution_version'] = '5.6.0'
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'install zookeeper package' do
      expect(chef_run).to install_package('zookeeper')
    end
  end
end

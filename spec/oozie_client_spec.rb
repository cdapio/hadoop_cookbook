require 'spec_helper'

describe 'hadoop::oozie_client' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.3.4.7'
      end.converge(described_recipe)
    end

    it 'install oozie-client package' do
      expect(chef_run).to install_package('oozie_2_3_4_7_4-client')
    end
  end

  context 'on CDH' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
      end.converge(described_recipe)
    end

    it 'install oozie-client package' do
      expect(chef_run).to install_package('oozie-client')
    end
  end
end

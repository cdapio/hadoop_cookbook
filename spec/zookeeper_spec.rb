require 'spec_helper'

describe 'hadoop::zookeeper' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'hdp'
        node.override['hadoop']['distribution_version'] = '2.3.4.7'
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'install zookeeper package' do
      expect(chef_run).to install_package('zookeeper_2_3_4_7_4')
    end
  end
end

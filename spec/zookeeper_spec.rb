require 'spec_helper'

describe 'hadoop::zookeeper' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'install zookeeper package' do
      expect(chef_run).to install_package('zookeeper')
    end
  end
end

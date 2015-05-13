require 'spec_helper'

describe 'hadoop::oozie_client' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
      end.converge(described_recipe)
    end

    it 'install oozie-client package' do
      expect(chef_run).to install_package('oozie-client')
    end
  end
end

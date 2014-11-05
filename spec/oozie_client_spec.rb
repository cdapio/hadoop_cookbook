require 'spec_helper'

describe 'hadoop::oozie_client' do
  context 'on Centos 6.5 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.5) do |node|
        node.automatic['domain'] = 'example.com'
      end.converge(described_recipe)
    end

    it 'install oozie-client package' do
      expect(chef_run).to install_package('oozie-client')
    end
  end
end

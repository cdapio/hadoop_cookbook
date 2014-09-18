require 'spec_helper'

describe 'hadoop::flume_agent' do
  context 'on Centos 6.5 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.5) do |node|
        node.automatic['domain'] = 'example.com'
      end.converge(described_recipe)
    end

    it 'install flume-agent package' do
      expect(chef_run).to install_package('flume-agent')
    end

    it 'creates flume-agent service resource, but does not run it' do
      expect(chef_run).to_not start_service('flume-agent')
    end
  end

  context 'using CDH' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.5) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
      end.converge(described_recipe)
    end

    it 'install flume-ng package' do
      expect(chef_run).to install_package('flume-ng-agent')
    end
  end
end

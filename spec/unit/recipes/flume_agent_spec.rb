require 'spec_helper'

describe 'hadoop::flume_agent' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.3.4.7'
      end.converge(described_recipe)
    end

    it 'install flume-agent package' do
      expect(chef_run).to install_package('flume_2_3_4_7_4-agent')
    end

    it 'creates flume-agent service resource, but does not run it' do
      expect(chef_run.service('flume-agent')).to do_nothing
    end

    context 'using CDH' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.automatic['domain'] = 'example.com'
          node.override['hadoop']['distribution'] = 'cdh'
        end.converge(described_recipe)
      end

      it 'install flume-ng package' do
        expect(chef_run).to install_package('flume-ng-agent')
      end
    end
  end
end

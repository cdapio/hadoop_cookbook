require 'spec_helper'

describe 'hadoop::flume' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['flume']['flume_conf']['key'] = 'value'
      end.converge(described_recipe)
    end

    it 'install flume package' do
      expect(chef_run).to install_package('flume')
    end

    it 'create /etc/flume/conf.chef directory' do
      expect(chef_run).to create_directory('/etc/flume/conf.chef')
    end

    it 'create /etc/flume/conf.chef/flume.conf from template' do
      expect(chef_run).to create_template('/etc/flume/conf.chef/flume.conf')
    end
  end

  context 'using CDH' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
      end.converge(described_recipe)
    end

    it 'install flume-ng package' do
      expect(chef_run).to install_package('flume-ng')
    end
  end
end

require 'spec_helper'

describe 'hadoop::hive_server' do
  context 'on Centos 6.5 x86_64' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.5) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
        stub_command('update-alternatives --display hive-conf | grep best | awk \'{print $5}\' | grep /etc/hive/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install hive-server package' do
      expect(chef_run).to install_package('hive-server')
    end

    it 'creates hive-server service resource, but does not run it' do
      expect(chef_run).to_not start_service('hive-server')
    end
  end
end

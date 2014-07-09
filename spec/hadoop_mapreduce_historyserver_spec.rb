require 'spec_helper'

describe 'hadoop::hadoop_mapreduce_historyserver' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'installs hadoop-mapreduce-historyserver package' do
      expect(chef_run).to install_package('hadoop-mapreduce-historyserver')
    end

    it 'creates hadoop-mapreduce-historyserver service resource, but does not run it' do
      expect(chef_run).to_not start_service('hadoop-mapreduce-historyserver')
    end
  end
end

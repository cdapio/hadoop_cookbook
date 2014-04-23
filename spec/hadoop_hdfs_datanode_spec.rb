require 'spec_helper'

describe 'hadoop::hadoop_hdfs_datanode' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install hadoop-hdfs-datanode package' do
      expect(chef_run).to install_package('hadoop-hdfs-datanode')
    end

    it 'creates HDFS data dir' do
      expect(chef_run).to create_directory('/tmp/hadoop-hdfs/dfs/data').with(
        user: 'hdfs',
        group: 'hdfs'
      )
    end

    it 'creates hadoop-hdfs-datanode service resource, but does not run it' do
      expect(chef_run).to_not start_service('hadoop-hdfs-datanode')
    end
  end
end

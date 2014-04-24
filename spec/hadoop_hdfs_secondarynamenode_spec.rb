require 'spec_helper'

describe 'hadoop::hadoop_hdfs_secondarynamenode' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.namenode.checkpoint.dir'] = '/tmp/hadoop-hdfs/dfs/namesecondary'
        node.default['hadoop']['hdfs_site']['dfs.namenode.checkpoint.edits.dir'] = '/tmp/hadoop-hdfs/dfs/namesecondaryedits'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install hadoop-hdfs-secondarynamenode package' do
      expect(chef_run).to install_package('hadoop-hdfs-secondarynamenode')
    end

    it 'creates HDFS checkpoint dirs' do
      expect(chef_run).to create_directory('/tmp/hadoop-hdfs/dfs/namesecondary').with(
        user: 'hdfs',
        group: 'hdfs'
      )
      expect(chef_run).to create_directory('/tmp/hadoop-hdfs/dfs/namesecondaryedits').with(
        user: 'hdfs',
        group: 'hdfs'
      )
    end

    it 'creates hadoop-hdfs-secondarynamenode service resource, but does not run it' do
      expect(chef_run).to_not start_service('hadoop-hdfs-secondarynamenode')
    end
  end
end

require 'spec_helper'

describe 'hadoop::hbase_master' do
  context 'on Centos 6.4 in distributed mode' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.datanode.max.transfer.threads'] = '4096'
        node.default['hbase']['hbase_site']['hbase.rootdir'] = 'hdfs://localhost:8020/hbase'
        node.default['hbase']['hbase_site']['hbase.zookeeper.quorum'] = 'localhost'
        node.default['hbase']['hbase_site']['hbase.cluster.distributed'] = 'true'
        stub_command('update-alternatives --display hbase-conf | grep best | awk \'{print $5}\' | grep /etc/hbase/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install hbase-master package' do
      expect(chef_run).to install_package('hbase-master')
    end

    it 'creates hbase-master service resource, but does not run it' do
      expect(chef_run).to_not start_service('hbase-master')
    end

    it 'creates hbase-hdfs-rootdir execute resource, but does not run it' do
      expect(chef_run).to_not run_execute('hbase-hdfs-rootdir').with(user: 'hdfs')
    end

    it 'creates hbase-bulkload-stagingdir execute resource, but does not run it' do
      expect(chef_run).to_not run_execute('hbase-bulkload-stagingdir').with(user: 'hdfs')
    end
  end

  context 'on Centos 6.4 in local mode' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.datanode.max.transfer.threads'] = '4096'
        node.default['hbase']['hbase_site']['hbase.rootdir'] = 'file:///tmp/hbase'
        node.default['hbase']['hbase_site']['hbase.zookeeper.quorum'] = 'localhost'
        node.default['hbase']['hbase_site']['hbase.cluster.distributed'] = 'false'
        stub_command('update-alternatives --display hbase-conf | grep best | awk \'{print $5}\' | grep /etc/hbase/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'creates hbase.rootdir directory' do
      expect(chef_run).to create_directory('/tmp/hbase')
    end

  end
end

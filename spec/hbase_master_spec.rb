require 'spec_helper'

describe 'hadoop::hbase_master' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.datanode.max.xcievers'] = '4096'
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
  end
end

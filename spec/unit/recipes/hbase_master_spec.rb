require 'spec_helper'

describe 'hadoop::hbase_master' do
  context 'on CentOS 6.9' do
    context 'in distributed mode' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.automatic['domain'] = 'example.com'
          node.default['hadoop']['hdfs_site']['dfs.datanode.max.transfer.threads'] = '4096'
          node.default['hbase']['hbase_site']['hbase.rootdir'] = 'hdfs://localhost:8020/hbase'
          node.default['hbase']['hbase_site']['hbase.zookeeper.quorum'] = 'localhost'
          node.default['hbase']['hbase_site']['hbase.cluster.distributed'] = 'true'
          stub_command(/test -L /).and_return(false)
          stub_command(/update-alternatives --display /).and_return(false)
          stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
        end.converge(described_recipe)
      end
      pkg = 'hbase-master'

      %W(
        /etc/default/#{pkg}
        /etc/init.d/#{pkg}
      ).each do |file|
        it "creates #{file} from template" do
          expect(chef_run).to create_template(file)
        end
      end

      it "creates #{pkg} service resource, but does not run it" do
        expect(chef_run.service(pkg)).to do_nothing
      end

      %w(
        hbase-bulkload-stagingdir
        hbase-hdfs-rootdir
      ).each do |dir|
        it "creates #{dir} execute resource, but does not run it" do
          expect(chef_run.execute(dir)).to do_nothing
        end
      end
    end

    context 'in local mode' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.automatic['domain'] = 'example.com'
          node.default['hadoop']['hdfs_site']['dfs.datanode.max.transfer.threads'] = '4096'
          node.override['hbase']['hbase_site']['hbase.rootdir'] = 'file:///tmp/hbase'
          node.default['hbase']['hbase_site']['hbase.zookeeper.quorum'] = 'localhost'
          node.default['hbase']['hbase_site']['hbase.cluster.distributed'] = 'false'
          stub_command(/test -L /).and_return(false)
          stub_command(/update-alternatives --display /).and_return(false)
          stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
        end.converge(described_recipe)
      end

      it 'creates hbase.rootdir directory' do
        expect(chef_run).to create_directory('/tmp/hbase')
      end
    end
  end
end

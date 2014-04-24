require 'spec_helper'

describe 'hadoop::hbase' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.datanode.max.xcievers'] = '4096'
        node.default['hbase']['hbase_site']['hbase.rootdir'] = 'hdfs://localhost:8020/hbase'
        stub_command('update-alternatives --display hbase-conf | grep best | awk \'{print $5}\' | grep /etc/hbase/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install hbase package' do
      expect(chef_run).to install_package('hbase')
    end

    it 'installs snappy package' do
      expect(chef_run).to install_package('snappy')
    end

    it 'creates hbase conf_dir' do
      expect(chef_run).to create_directory('/etc/hbase/conf.chef').with(
        user: 'root',
        group: 'root'
      )
    end

    %w(hbase-policy.xml hbase-site.xml).each do |xml|
      it "creates #{xml} from template" do
        expect(chef_run).to create_template("/etc/hbase/conf.chef/#{xml}")
      end
    end

    it 'runs execute[update hbase-conf alternatives]' do
      expect(chef_run).to run_execute('update hbase-conf alternatives')
    end
  end

  context 'on Ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'ubuntu', version: 12.04) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.datanode.max.xcievers'] = '4096'
        stub_command('update-alternatives --display hbase-conf | grep best | awk \'{print $5}\' | grep /etc/hbase/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install libsnappy1 package' do
      expect(chef_run).to install_package('libsnappy1')
    end
  end
end

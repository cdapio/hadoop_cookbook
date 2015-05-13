require 'spec_helper'

describe 'hadoop::hbase' do
  context 'on Centos 6.6 x86_64' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.datanode.max.xcievers'] = '4096'
        node.default['hbase']['hbase_site']['hbase.rootdir'] = 'hdfs://localhost:8020/hbase'
        node.default['hbase']['hbase_env']['hbase_log_dir'] = '/data/log/hbase'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
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

    it 'creates hbase HBASE_LOG_DIR' do
      expect(chef_run).to create_directory('/data/log/hbase').with(
        mode: '0755',
        user: 'hbase',
        group: 'hbase'
      )
    end

    it 'deletes /var/log/hbase' do
      expect(chef_run).to delete_directory('/var/log/hbase')
    end

    it 'creates /var/log/hbase symlink' do
      link = chef_run.link('/var/log/hbase')
      expect(link).to link_to('/data/log/hbase')
    end

    it 'creates /etc/hbase/conf.chef/hbase-env.sh template' do
      expect(chef_run).to create_template('/etc/hbase/conf.chef/hbase-env.sh')
    end

    it 'sets hbase limits' do
      expect(chef_run).to create_ulimit_domain('hbase')
    end

    it 'runs execute[update hbase-conf alternatives]' do
      expect(chef_run).to run_execute('update hbase-conf alternatives')
    end
  end

  context 'on Ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 12.04) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.datanode.max.xcievers'] = '4096'
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'install libsnappy1 package' do
      expect(chef_run).to install_package('libsnappy1')
    end
  end
end

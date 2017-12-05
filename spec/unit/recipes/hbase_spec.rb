require 'spec_helper'

describe 'hadoop::hbase' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.datanode.max.xcievers'] = '4096'
        node.default['hbase']['hadoop_metrics']['foo'] = 'bar'
        node.default['hbase']['hbase_site']['hbase.rootdir'] = 'hdfs://localhost:8020/hbase'
        node.default['hbase']['hbase_env']['hbase_log_dir'] = '/data/log/hbase'
        node.default['hbase']['log4j']['log4j.threshold'] = 'ALL'
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.3.4.7'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'installs hbase package' do
      expect(chef_run).to install_package('hbase_2_3_4_7_4')
    end

    it 'creates hbase conf_dir' do
      expect(chef_run).to create_directory('/etc/hbase/conf.chef').with(
        user: 'root',
        group: 'root'
      )
    end

    %w(
      hadoop-metrics.properties
      hbase-env.sh
      hbase-policy.xml
      hbase-site.xml
      log4j.properties
    ).each do |file|
      it "creates #{file} from template" do
        expect(chef_run).to create_template("/etc/hbase/conf.chef/#{file}")
      end
    end

    it 'creates /etc/default/hbase from template' do
      expect(chef_run).to create_template('/etc/default/hbase')
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

    it 'sets hbase limits' do
      expect(chef_run).to create_ulimit_domain('hbase')
    end

    it 'deletes /etc/hbase/conf directory' do
      expect(chef_run).to delete_directory('/etc/hbase/conf')
    end

    it 'runs execute[update hbase-conf alternatives]' do
      expect(chef_run).to run_execute('update hbase-conf alternatives')
    end
  end

  context 'on Ubuntu 14.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 14.04) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.datanode.max.xcievers'] = '4096'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'installs hbase package' do
      expect(chef_run).to install_package('hbase')
    end
  end
end

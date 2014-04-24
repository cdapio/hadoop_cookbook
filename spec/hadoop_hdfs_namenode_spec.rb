require 'spec_helper'

describe 'hadoop::hadoop_hdfs_namenode' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install hadoop-hdfs-namenode package' do
      expect(chef_run).to install_package('hadoop-hdfs-namenode')
    end

    it 'creates HDFS name dir' do
      expect(chef_run).to create_directory('/tmp/hadoop-hdfs/dfs/name').with(
        user: 'hdfs',
        group: 'hdfs'
      )
    end

    it 'creates hdfs-namenode-format execute resource, but does not run it' do
      expect(chef_run).to_not run_execute('hdfs-namenode-format').with(user: 'hdfs')
    end

    it 'creates hadoop-hdfs-namenode service resource, but does not run it' do
      expect(chef_run).to_not disable_service('hadoop-hdfs-namenode')
      expect(chef_run).to_not enable_service('hadoop-hdfs-namenode')
      expect(chef_run).to_not reload_service('hadoop-hdfs-namenode')
      expect(chef_run).to_not restart_service('hadoop-hdfs-namenode')
      expect(chef_run).to_not start_service('hadoop-hdfs-namenode')
      expect(chef_run).to_not stop_service('hadoop-hdfs-namenode')
    end
  end
end

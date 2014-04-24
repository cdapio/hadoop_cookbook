require 'spec_helper'

describe 'hadoop::hadoop_hdfs_zkfc' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.nameservices'] = 'hdfs'
        node.default['hadoop']['hdfs_site']['fs.defaultFS'] = 'hdfs://hdfs'
        node.default['hadoop']['hdfs_site']['dfs.ha.fencing.methods'] = 'something'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install hadoop-hdfs-zkfc package' do
      expect(chef_run).to install_package('hadoop-hdfs-zkfc')
    end

    it 'creates hadoop-hdfs-zkfc service resource, but does not run it' do
      expect(chef_run).to_not start_service('hadoop-hdfs-zkfc')
    end
  end
end

require 'spec_helper'

describe 'hadoop::hadoop_yarn_resourcemanager' do
  context 'on Centos 6.5 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.5) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install hadoop-yarn-resourcemanager package' do
      expect(chef_run).to install_package('hadoop-yarn-resourcemanager')
    end

    it 'creates hdfs-tmpdir execute resource, but does not run it' do
      expect(chef_run).to_not run_execute('hdfs-tmpdir').with(user: 'hdfs')
    end

    it 'creates yarn-remote-app-log-dir execute resource, but does not run it' do
      expect(chef_run).to_not run_execute('yarn-remote-app-log-dir').with(user: 'hdfs')
    end

    it 'creates hadoop-yarn-resourcemanager service resource, but does not run it' do
      expect(chef_run).to_not start_service('hadoop-yarn-resourcemanager')
    end
  end
end

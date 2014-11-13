require 'spec_helper'

describe 'hadoop::spark_historyserver' do
  context 'on Centos 6.5 x86_64' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.5) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['spark']['release']['install'] = true
        stub_command('test -L /var/log/spark').and_return(false)
        stub_command('update-alternatives --display spark-conf | grep best | awk \'{print $5}\' | grep /etc/spark/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'does not install spark-history-server package' do
      expect(chef_run).not_to install_package('spark-history-server')
    end

    it 'creates hdfs-spark-userdir execute resource, but does not run it' do
      expect(chef_run).to_not run_execute('hdfs-spark-userdir').with(user: 'hdfs')
    end

    it 'creates hdfs-spark-eventlog-dir execute resource, but does not run it' do
      expect(chef_run).to_not run_execute('hdfs-spark-eventlog-dir').with(user: 'hdfs')
    end
  end

  context 'using CDH 5' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.5) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
        node.override['hadoop']['distribution_version'] = 5
        stub_command('test -L /var/log/spark').and_return(false)
        stub_command('update-alternatives --display spark-conf | grep best | awk \'{print $5}\' | grep /etc/spark/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'installs spark-history-server package' do
      expect(chef_run).to install_package('spark-history-server')
    end

    it 'creates spark-history-server service resource, but does not run it' do
      expect(chef_run).to_not start_service('spark-history-server')
    end
  end
end

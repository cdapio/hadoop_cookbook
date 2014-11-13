require 'spec_helper'

describe 'hadoop::spark_master' do
  context 'on Centos 6.5 x86_64' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.5) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['spark']['release']['install'] = true
        stub_command('test -L /var/log/spark').and_return(false)
        stub_command('update-alternatives --display spark-conf | grep best | awk \'{print $5}\' | grep /etc/spark/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'does not install spark-master package' do
      expect(chef_run).not_to install_package('spark-master')
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

    it 'installs spark-master package' do
      expect(chef_run).to install_package('spark-master')
    end

    it 'creates spark-master service resource, but does not run it' do
      expect(chef_run).to_not start_service('spark-master')
    end
  end
end

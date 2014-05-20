require 'spec_helper'

describe 'hadoop::hadoop_mapreduce_jobtracker' do
  context 'on Centos 6.4 with CDH' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'installs hadoop-0.20-mapreduce-jobtracker package' do
      expect(chef_run).to install_package('hadoop-0.20-mapreduce-jobtracker')
    end

    it 'creates hadoop-0.20-mapreduce-jobtracker service resource, but does not run it' do
      expect(chef_run).to_not start_service('hadoop-0.20-mapreduce-jobtracker')
    end
  end

  context 'on Centos 6.4 with HDP' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'does not install hadoop-0.20-mapreduce-jobtracker package' do
      expect(chef_run).not_to install_package('hadoop-0.20-mapreduce-jobtracker')
    end
  end
end

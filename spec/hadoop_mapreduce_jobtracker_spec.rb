require 'spec_helper'

describe 'hadoop::hadoop_mapreduce_jobtracker' do
  context 'on Centos 6.6 with CDH' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
        stub_command(/update-alternatives --display /).and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
        stub_command(/test -L /).and_return(false)
      end.converge(described_recipe)
    end
    pkg = 'hadoop-0.20-mapreduce-jobtracker'

    it "does not install #{pkg} package" do
      expect(chef_run).not_to install_package(pkg)
    end

    it "runs package-#{pkg} ruby_block" do
      expect(chef_run).to run_ruby_block("package-#{pkg}")
    end

    it "creates #{pkg} service resource, but does not run it" do
      expect(chef_run).to_not disable_service(pkg)
      expect(chef_run).to_not enable_service(pkg)
      expect(chef_run).to_not reload_service(pkg)
      expect(chef_run).to_not restart_service(pkg)
      expect(chef_run).to_not start_service(pkg)
      expect(chef_run).to_not stop_service(pkg)
    end

    it 'creates local dir' do
      expect(chef_run).to create_directory('/tmp/hadoop-mapred/local').with(
        user: 'mapred',
        group: 'mapred'
      )
    end
  end

  context 'on Centos 6.6 with HDP' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command(/update-alternatives --display /).and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
        stub_command(/test -L /).and_return(false)
      end.converge(described_recipe)
    end
    pkg = 'hadoop-0.20-mapreduce-jobtracker'

    it "does not install #{pkg} package" do
      expect(chef_run).not_to install_package(pkg)
    end
  end
end

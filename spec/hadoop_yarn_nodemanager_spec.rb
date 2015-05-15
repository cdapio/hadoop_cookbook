require 'spec_helper'

describe 'hadoop::hadoop_yarn_nodemanager' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command(/update-alternatives --display /).and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
      end.converge(described_recipe)
    end
    pkg = 'hadoop-yarn-nodemanager'

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

    it 'ensures /usr/lib/hadoop-yarn/bin/container-executor has proper permissions' do
      expect(chef_run).to create_file('/usr/lib/hadoop-yarn/bin/container-executor').with(
        user: 'root',
        group: 'yarn',
        mode: '6050'
      )
    end
  end

  context 'using HDP 2.2' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.override['hadoop']['distribution'] = 'hdp'
        node.override['hadoop']['distribution_version'] = '2.2.4.2'
        node.automatic['domain'] = 'example.com'
        stub_command(/update-alternatives --display /).and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
      end.converge(described_recipe)
    end

    it 'ensures /usr/hdp/current/hadoop-yarn-nodemanager/bin/container-executor has proper permissions' do
      expect(chef_run).to create_file('/usr/hdp/current/hadoop-yarn-nodemanager/bin/container-executor').with(
        user: 'root',
        group: 'yarn',
        mode: '6050'
      )
    end
  end
end

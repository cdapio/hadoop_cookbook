require 'spec_helper'

describe 'hadoop::hadoop_yarn_nodemanager' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.3.4.7'
        node.automatic['domain'] = 'example.com'
        stub_command(/update-alternatives --display /).and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
        stub_command(/test -L /).and_return(false)
      end.converge(described_recipe)
    end
    pkg = 'hadoop-yarn-nodemanager'

    %W(
      /etc/default/#{pkg}
      /etc/init.d/#{pkg}
    ).each do |file|
      it "creates #{file} from template" do
        expect(chef_run).to create_template(file)
      end
    end

    it "creates #{pkg} service resource, but does not run it" do
      expect(chef_run.service(pkg)).to do_nothing
    end

    it 'ensures /usr/hdp/2.3.4.7-4/hadoop-yarn/bin/container-executor has proper permissions' do
      expect(chef_run).to create_file('/usr/hdp/2.3.4.7-4/hadoop-yarn/bin/container-executor').with(
        user: 'root',
        group: 'yarn',
        mode: '6050'
      )
    end

    context 'using HDP 2.1.15.0' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.default['hadoop']['distribution'] = 'hdp'
          node.default['hadoop']['distribution_version'] = '2.1.15.0'
          node.automatic['domain'] = 'example.com'
          stub_command(/update-alternatives --display /).and_return(false)
          stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
          stub_command(/test -L /).and_return(false)
        end.converge(described_recipe)
      end

      it 'ensures /usr/lib/hadoop-yarn/bin/container-executor has proper permissions' do
        expect(chef_run).to create_file('/usr/lib/hadoop-yarn/bin/container-executor').with(
          user: 'root',
          group: 'yarn',
          mode: '6050'
        )
      end
    end
  end
end

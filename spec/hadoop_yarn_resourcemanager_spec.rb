require 'spec_helper'

describe 'hadoop::hadoop_yarn_resourcemanager' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command(/update-alternatives --display /).and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
        stub_command(/test -L /).and_return(false)
      end.converge(described_recipe)
    end
    pkg = 'hadoop-yarn-resourcemanager'

    %W(
      /etc/default/#{pkg}
      /etc/init.d/#{pkg}
    ).each do |file|
      it "creates #{file} from template" do
        expect(chef_run).to create_template(file)
      end
    end

    it "creates #{pkg} service resource, but does not run it" do
      expect(chef_run).to_not disable_service(pkg)
      expect(chef_run).to_not enable_service(pkg)
      expect(chef_run).to_not reload_service(pkg)
      expect(chef_run).to_not restart_service(pkg)
      expect(chef_run).to_not start_service(pkg)
      expect(chef_run).to_not stop_service(pkg)
    end

    it 'creates hdfs-tmpdir execute resource, but does not run it' do
      expect(chef_run).to_not run_execute('hdfs-tmpdir').with(user: 'hdfs')
    end

    it 'creates yarn-remote-app-log-dir execute resource, but does not run it' do
      expect(chef_run).to_not run_execute('yarn-remote-app-log-dir').with(user: 'hdfs')
    end

    it 'creates yarn-app-mapreduce-am-staging-dir execute resource, but does not run it' do
      expect(chef_run).to_not run_execute('yarn-app-mapreduce-am-staging-dir').with(user: 'hdfs')
    end

    it 'creates hdp22-mapreduce-tarball execute resource, but does not run it' do
      expect(chef_run).to_not run_execute('hdp22-mapreduce-tarball').with(user: 'hdfs')
    end
  end
end

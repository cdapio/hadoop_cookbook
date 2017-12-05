require 'spec_helper'

describe 'hadoop::hadoop_yarn_resourcemanager' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
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
      expect(chef_run.service(pkg)).to do_nothing
    end

    %w(
      hdfs-tmpdir
      hdp22-mapreduce-tarball
      yarn-app-mapreduce-am-staging-dir
      yarn-remote-app-log-dir
    ).each do |exec|
      it "creates #{exec} resource, but does not run it" do
        expect(chef_run.execute(exec)).to do_nothing
      end
    end
  end
end

require 'spec_helper'

describe 'hadoop::hadoop_hdfs_namenode' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command(/update-alternatives --display /).and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
        stub_command(/test -L /).and_return(false)
      end.converge(described_recipe)
    end
    pkg = 'hadoop-hdfs-namenode'

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

    it 'creates HDFS name dir' do
      expect(chef_run).to create_directory('/tmp/hadoop-hdfs/dfs/name').with(
        user: 'hdfs',
        group: 'hdfs'
      )
    end

    %w(hdfs-namenode-format hdfs-namenode-bootstrap-standby hdfs-namenode-initialize-sharededits).each do |exec|
      it "creates #{exec} execute resource, but does not run it" do
        expect(chef_run.execute(exec)).to do_nothing
      end
    end
  end
end

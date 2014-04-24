require 'spec_helper'

describe 'hadoop::default' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.datanode.max.xcievers'] = '4096'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install hadoop-client package' do
      expect(chef_run).to install_package('hadoop-client')
    end

    it 'creates Hadoop conf_dir' do
      expect(chef_run).to create_directory('/etc/hadoop/conf.chef').with(
        user: 'root',
        group: 'root'
      )
    end

    %w(hadoop-hdfs hadoop-mapreduce hadoop-yarn).each do |dir|
      it "creates #{dir} directory" do
        expect(chef_run).to create_directory("/tmp/#{dir}").with(
          mode: '1777'
        )
      end
    end

    %w(capacity-scheduler.xml core-site.xml hdfs-site.xml yarn-site.xml).each do |xml|
      it "creates #{xml} template" do
        expect(chef_run).to create_template("/etc/hadoop/conf.chef/#{xml}")
      end
    end

    it 'renders file capacity-scheduler.xml with yarn.scheduler.capacity.maximum-applications' do
      expect(chef_run).to render_file('/etc/hadoop/conf.chef/capacity-scheduler.xml').with_content(
        /yarn.scheduler.capacity.maximum-applications/
      )
    end

    it 'renders file core-site.xml with fs.defaultFS' do
      expect(chef_run).to render_file('/etc/hadoop/conf.chef/core-site.xml').with_content(
        /fs.defaultFS/
      )
    end

    it 'renders file hdfs-site.xml with dfs.datanode.max.xcievers' do
      expect(chef_run).to render_file('/etc/hadoop/conf.chef/hdfs-site.xml').with_content(
        /dfs.datanode.max.xcievers/
      )
    end

    it 'runs execute[update hadoop-conf alternatives]' do
      expect(chef_run).to run_execute('update hadoop-conf alternatives')
    end
  end
end

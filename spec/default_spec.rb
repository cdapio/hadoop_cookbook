require 'spec_helper'

describe 'hadoop::default' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.datanode.max.transfer.threads'] = '4096'
        node.default['hadoop']['hadoop_policy']['test.property'] = 'blue'
        node.default['hadoop']['mapred_site']['mapreduce.framework.name'] = 'yarn'
        node.default['hadoop']['fair_scheduler']['defaults']['poolMaxJobsDefault'] = '1000'
        node.default['hadoop']['hadoop_env']['hadoop_log_dir'] = '/var/log/hadoop-hdfs'
        node.default['hadoop']['yarn_env']['yarn_log_dir'] = '/var/log/hadoop-yarn'
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
      it "creates /tmp/#{dir} directory" do
        expect(chef_run).to create_directory("/tmp/#{dir}").with(
          mode: '1777'
        )
      end
    end

    %w(hadoop-hdfs hadoop-yarn).each do |dir|
      it "creates /var/log/#{dir} directory" do
        expect(chef_run).to create_directory("/var/log/#{dir}").with(
          mode: '0755'
        )
      end
    end

    %w(
      capacity-scheduler.xml
      core-site.xml
      fair-scheduler.xml
      hadoop-env.sh
      hadoop-policy.xml
      hdfs-site.xml
      mapred-site.xml
      yarn-env.sh
      yarn-site.xml
    ).each do |file|
      it "creates #{file} from template" do
        expect(chef_run).to create_template("/etc/hadoop/conf.chef/#{file}")
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

    it 'renders file fair-scheduler.xml with poolMaxJobsDefault' do
      expect(chef_run).to render_file('/etc/hadoop/conf.chef/fair-scheduler.xml').with_content(
        /poolMaxJobsDefault/
      )
    end

    it 'renders file hadoop-env.sh with HADOOP_LOG_DIR' do
      expect(chef_run).to render_file('/etc/hadoop/conf.chef/hadoop-env.sh').with_content(
        /HADOOP_LOG_DIR/
      )
    end

    it 'renders file hadoop-policy.xml with test.property' do
      expect(chef_run).to render_file('/etc/hadoop/conf.chef/hadoop-policy.xml').with_content(
        /test.property/
      )
    end

    it 'renders file hdfs-site.xml with dfs.datanode.max.transfer.threads' do
      expect(chef_run).to render_file('/etc/hadoop/conf.chef/hdfs-site.xml').with_content(
        /dfs.datanode.max.transfer.threads/
      )
    end

    it 'renders file mapred-site.xml with mapreduce.framework.name' do
      expect(chef_run).to render_file('/etc/hadoop/conf.chef/mapred-site.xml').with_content(
        /mapreduce.framework.name/
      )
    end

    it 'renders file yarn-env.sh with YARN_LOG_DIR' do
      expect(chef_run).to render_file('/etc/hadoop/conf.chef/yarn-env.sh').with_content(
        /YARN_LOG_DIR/
      )
    end

    it 'runs execute[update hadoop-conf alternatives]' do
      expect(chef_run).to run_execute('update hadoop-conf alternatives')
    end
  end
end

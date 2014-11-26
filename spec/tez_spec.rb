require 'spec_helper'

describe 'hadoop::tez' do
  context 'on Centos 6.5 x86_64' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.5) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command('hdfs dfs -test -d hdfs://fauxhai.local/apps/tez').and_return(false)
        stub_command('update-alternatives --display tez-conf | grep best | awk \'{print $5}\' | grep /etc/tez/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    %w(HDP-2.x Updates-HDP-2.x HDP-UTILS-1.1.0.19).each do |repo|
      it "add #{repo} yum_repository" do
        expect(chef_run).to add_yum_repository(repo)
      end
    end

    it 'install tez package' do
      expect(chef_run).to install_package('tez')
    end

    it 'executes execute[tez-hdfs-appdir]' do
      expect(chef_run).to_not run_execute('tez-hdfs-appdir')
    end

    it 'executes execute[hive-hdfs-appdir]' do
      expect(chef_run).to_not run_execute('hive-hdfs-appdir')
    end

    it 'executes execute[update tez-conf alternatives]' do
      expect(chef_run).to run_execute('update tez-conf alternatives')
    end

    %w(/etc/tez/conf.chef).each do |directory|
      it "creates #{directory} directory" do
        expect(chef_run).to create_directory(directory)
      end
    end

    %w(/etc/tez/conf.chef/tez-site.xml /etc/tez/conf.chef/tez-env.sh).each do |template|
      it "creates #{template} template" do
        expect(chef_run).to create_template(template)
      end
    end
  end
end

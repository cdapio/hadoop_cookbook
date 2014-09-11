require 'spec_helper'

describe 'hadoop::hive' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hive']['hive_site']['hive.exec.local.scratchdir'] = '/tmp'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
        stub_command('update-alternatives --display hive-conf | grep best | awk \'{print $5}\' | grep /etc/hive/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install hive package' do
      expect(chef_run).to install_package('hive')
    end

    %w(mysql-connector-java postgresql-jdbc).each do |pkg|
      it "install #{pkg} package" do
        expect(chef_run).to install_package(pkg)
      end
      it "link #{pkg}.jar" do
        link = chef_run.link("/usr/lib/hive/lib/#{pkg}.jar")
        expect(link).to link_to("/usr/share/java/#{pkg}.jar")
      end
    end

    %w(/etc/hive/conf.chef /var/lib/hive).each do |dir|
      it "creates directory #{dir}" do
        expect(chef_run).to create_directory(dir)
      end
    end

    it 'does not execute execute[hive-hdfs-homedir]' do
      expect(chef_run).not_to run_execute('hive-hdfs-homedir')
    end
    it 'executes execute[update hive-conf alternatives]' do
      expect(chef_run).to run_execute('update hive-conf alternatives')
    end

  end
  context 'on Ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'ubuntu', version: 12.04) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hive']['hive_site']['hive.exec.local.scratchdir'] = '/tmp'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
        stub_command('update-alternatives --display hive-conf | grep best | awk \'{print $5}\' | grep /etc/hive/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    %w(libmysql-java libpostgresql-jdbc-java).each do |pkg|
      it "install #{pkg} package" do
        expect(chef_run).to install_package(pkg)
      end
    end
    %w(mysql-connector-java postgresql-jdbc4).each do |jar|
      it "link #{jar}.jar" do
        link = chef_run.link("/usr/lib/hive/lib/#{jar}.jar")
        expect(link).to link_to("/usr/share/java/#{jar}.jar")
      end
    end

  end
end

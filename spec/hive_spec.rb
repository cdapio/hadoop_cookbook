require 'spec_helper'

describe 'hadoop::hive' do
  context 'on Centos 6.6 x86_64' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hive']['hive_site']['hive.exec.local.scratchdir'] = '/tmp/hive/scratch'
        node.default['hive']['hive_env']['hive_log_dir'] = '/data/log/hive'
        stub_command('test -L /var/log/hive').and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
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

    it 'creates hive HIVE_LOG_DIR' do
      expect(chef_run).to create_directory('/data/log/hive').with(
        mode: '0755',
        user: 'hive',
        group: 'hive'
      )
    end

    it 'deletes /var/log/hive' do
      expect(chef_run).to delete_directory('/var/log/hive')
    end

    it 'creates /var/log/hive symlink' do
      link = chef_run.link('/var/log/hive')
      expect(link).to link_to('/data/log/hive')
    end

    %w(
      /etc/hive/conf.chef/hive-site.xml
      /etc/hive/conf.chef/hive-env.sh
    ).each do |template|
      it "creates #{template} template" do
        expect(chef_run).to create_template(template)
      end
    end

    it 'creates /tmp/hive/scratch directory' do
      expect(chef_run).to create_directory('/tmp/hive/scratch')
    end
  end

  context 'using HDP 2.2' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.override['hadoop']['distribution'] = 'hdp'
        node.override['hadoop']['distribution_version'] = '2.2.4.2'
        node.automatic['domain'] = 'example.com'
        node.default['hive']['hive_site']['hive.exec.local.scratchdir'] = '/tmp/hive/scratch'
        node.default['hive']['hive_env']['hive_log_dir'] = '/data/log/hive'
        stub_command('test -L /var/log/hive').and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    %w(mysql-connector-java postgresql-jdbc).each do |pkg|
      it "link #{pkg}.jar" do
        link = chef_run.link("/usr/hdp/current/hive-client/lib/#{pkg}.jar")
        expect(link).to link_to("/usr/share/java/#{pkg}.jar")
      end
    end
  end

  context 'on Ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 12.04) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    %w(mysql-connector-java libpostgresql-jdbc-java).each do |pkg|
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

  context 'using 12.04 HDP 2.2' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 12.04) do |node|
        node.override['hadoop']['distribution'] = 'hdp'
        node.override['hadoop']['distribution_version'] = '2.2'
        node.automatic['domain'] = 'example.com'
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    %w(mysql-connector-java postgresql-jdbc4).each do |jar|
      it "link #{jar}.jar" do
        link = chef_run.link("/usr/hdp/current/hive-client/lib/#{jar}.jar")
        expect(link).to link_to("/usr/share/java/#{jar}.jar")
      end
    end
  end
end

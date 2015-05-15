require 'spec_helper'

describe 'hadoop::hive_metastore' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command(/update-alternatives --display /).and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
      end.converge(described_recipe)
    end
    pkg = 'hive-metastore'

    it "does not install #{pkg} package" do
      expect(chef_run).not_to install_package(pkg)
    end

    it "runs package-#{pkg} ruby_block" do
      expect(chef_run).to run_ruby_block("package-#{pkg}")
    end

    %w(mysql-connector-java postgresql-jdbc).each do |p|
      it "does not install #{p} package" do
        expect(chef_run).not_to install_package(p)
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

    it "creates /etc/init.d/#{pkg} from template" do
      expect(chef_run).to create_template('/etc/init.d/hive-metastore')
    end

    it 'does not run execute[hive-hdfs-warehousedir]' do
      expect(chef_run).not_to run_execute('hive-hdfs-warehousedir')
    end
  end

  context 'using MySQL on HDP 2.2' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.override['hadoop']['distribution'] = 'hdp'
        node.override['hadoop']['distribution_version'] = '2.2.4.2'
        node.override['hive']['hive_site']['javax.jdo.option.ConnectionURL'] = 'jdbc:mysql:localhost/hive'
        node.automatic['domain'] = 'example.com'
        node.default['hive']['hive_env']['hive_log_dir'] = '/data/log/hive'
        node.default['hive']['hive_site']['hive.exec.local.scratchdir'] = '/tmp/hive/scratch'
        stub_command('test -L /var/log/hive').and_return(false)
        stub_command('update-alternatives --display hive-conf | grep best | awk \'{print $5}\' | grep /etc/hive/conf.chef').and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
      end.converge(described_recipe)
    end

    it 'link mysql-connector-java.jar' do
      link = chef_run.link('/usr/hdp/current/hive-client/lib/mysql-connector-java.jar')
      expect(link).to link_to('/usr/share/java/mysql-connector-java.jar')
    end
  end

  context 'using PostgreSQL on Ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 12.04) do |node|
        node.override['hive']['hive_site']['javax.jdo.option.ConnectionURL'] = 'jdbc:postgresql:localhost/hive'
        node.automatic['domain'] = 'example.com'
        stub_command('update-alternatives --display hive-conf | grep best | awk \'{print $5}\' | grep /etc/hive/conf.chef').and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
      end.converge(described_recipe)
    end
    pkg = 'hive-metastore'

    it "does not install #{pkg} package" do
      expect(chef_run).not_to install_package(pkg)
    end

    it "runs package-#{pkg} ruby_block" do
      expect(chef_run).to run_ruby_block("package-#{pkg}")
    end

    it 'link postgresql-jdbc4.jar' do
      link = chef_run.link('/usr/lib/hive/lib/postgresql-jdbc4.jar')
      expect(link).to link_to('/usr/share/java/postgresql-jdbc4.jar')
    end
  end

  context 'using PostgreSQL on Ubuntu 12.04 HDP 2.2' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 12.04) do |node|
        node.override['hadoop']['distribution'] = 'hdp'
        node.override['hadoop']['distribution_version'] = '2.2.4.2'
        node.override['hive']['hive_site']['javax.jdo.option.ConnectionURL'] = 'jdbc:postgresql:localhost/hive'
        node.automatic['domain'] = 'example.com'
        stub_command('update-alternatives --display hive-conf | grep best | awk \'{print $5}\' | grep /etc/hive/conf.chef').and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
      end.converge(described_recipe)
    end

    it 'link postgresql-jdbc4.jar' do
      link = chef_run.link('/usr/hdp/current/hive-client/lib/postgresql-jdbc4.jar')
      expect(link).to link_to('/usr/share/java/postgresql-jdbc4.jar')
    end
  end
end

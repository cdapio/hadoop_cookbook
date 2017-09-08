require 'spec_helper'

describe 'hadoop::hive_metastore' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
      end.converge(described_recipe)
    end
    pkg = 'hive-metastore'

    %w(mysql-connector-java postgresql-jdbc).each do |p|
      it "does not install #{p} package" do
        expect(chef_run).not_to install_package(p)
      end
    end

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

    it 'does not run execute[hive-hdfs-warehousedir]' do
      expect(chef_run.execute('hive-hdfs-warehousedir')).to do_nothing
    end

    context 'using MySQL on HDP 2.3' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.default['hadoop']['distribution'] = 'hdp'
          node.default['hadoop']['distribution_version'] = '2.3.4.7'
          node.override['hive']['hive_site']['javax.jdo.option.ConnectionURL'] = 'jdbc:mysql:localhost/hive'
          node.automatic['domain'] = 'example.com'
          node.default['hive']['hive_env']['hive_log_dir'] = '/data/log/hive'
          node.default['hive']['hive_site']['hive.exec.local.scratchdir'] = '/tmp/hive/scratch'
          stub_command(/test -L /).and_return(false)
          stub_command(/update-alternatives --display /).and_return(false)
          stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
        end.converge(described_recipe)
      end

      it 'creates mysql-connector-java.jar symlink' do
        link = chef_run.link('/usr/hdp/2.3.4.7-4/hive/lib/mysql-connector-java.jar')
        expect(link).to link_to('/usr/share/java/mysql-connector-java.jar')
      end
    end
  end

  context 'using Ubuntu 14.04' do
    context 'using PostgreSQL' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 14.04) do |node|
          node.default['hadoop']['distribution'] = 'hdp'
          node.default['hadoop']['distribution_version'] = '2.3.4.7'
          node.override['hive']['hive_site']['javax.jdo.option.ConnectionURL'] = 'jdbc:postgresql:localhost/hive'
          node.automatic['domain'] = 'example.com'
          stub_command(/test -L /).and_return(false)
          stub_command(/update-alternatives --display /).and_return(false)
          stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
        end.converge(described_recipe)
      end

      it 'creates postgresql-jdbc4.jar symlink' do
        link = chef_run.link('/usr/hdp/2.3.4.7-4/hive/lib/postgresql-jdbc4.jar')
        expect(link).to link_to('/usr/share/java/postgresql-jdbc4.jar')
      end
    end

    context 'using PostgreSQL on HDP 2.1.15.0' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 14.04) do |node|
          node.default['hadoop']['distribution'] = 'hdp'
          node.default['hadoop']['distribution_version'] = '2.1.15.0'
          node.override['hive']['hive_site']['javax.jdo.option.ConnectionURL'] = 'jdbc:postgresql:localhost/hive'
          node.automatic['domain'] = 'example.com'
          stub_command(/test -L /).and_return(false)
          stub_command(/update-alternatives --display /).and_return(false)
          stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
        end.converge(described_recipe)
      end

      it 'creates postgresql-jdbc4.jar symlink' do
        link = chef_run.link('/usr/lib/hive/lib/postgresql-jdbc4.jar')
        expect(link).to link_to('/usr/share/java/postgresql-jdbc4.jar')
      end
    end
  end
end

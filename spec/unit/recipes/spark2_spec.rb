require 'spec_helper'

describe 'hadoop::spark2' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['spark2']['spark_env']['spark_log_dir'] = '/data/log/spark2'
        node.default['spark2']['spark_site']['spark.eventLog.enabled'] = false
        node.default['spark2']['metrics']['something.something'] = 'dark.side'
        node.default['spark2']['log4j']['root.logger'] = 'Console'
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.3.4.7'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'installs spark2 package' do
      expect(chef_run).to install_package('spark2_2_3_4_7_4')
    end

    it 'installs spark2-python package' do
      expect(chef_run).to install_package('spark2_2_3_4_7_4-python')
    end

    it 'installs libgfortran package' do
      expect(chef_run).to install_package('libgfortran')
    end

    it 'creates spark2 conf_dir' do
      expect(chef_run).to create_directory('/etc/spark2/conf.chef').with(
        user: 'root',
        group: 'root'
      )
    end

    it 'deletes /var/log/spark2 directory' do
      expect(chef_run).to delete_directory('/var/log/spark2')
    end

    it 'creates /data/log/spark2 directory' do
      expect(chef_run).to create_directory('/data/log/spark2').with(
        mode: '0755'
      )
    end

    it 'creates /var/log/spark2 symlink' do
      link = chef_run.link('/var/log/spark2')
      expect(link).to link_to('/data/log/spark2')
    end

    %w(
      spark-env.sh
      spark-defaults.conf
      metrics.properties
      log4j.properties
    ).each do |file|
      it "creates #{file} from template" do
        expect(chef_run).to create_template("/etc/spark2/conf.chef/#{file}")
      end
    end

    it 'deletes /etc/spark2/conf directory' do
      expect(chef_run).to delete_directory('/etc/spark2/conf')
    end

    it 'runs execute[update spark2-conf alternatives]' do
      expect(chef_run).to run_execute('update spark2-conf alternatives')
    end
  end

  context 'using HDP 2.1 and Spark release tarball' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['spark2']['release']['install'] = true
        node.default['spark2']['spark_env']['spark_log_dir'] = '/data/log/spark2'
        node.default['spark2']['spark_site']['spark.eventLog.enabled'] = false
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'does not install spark2-core package' do
      expect(chef_run).not_to install_package('spark2-core')
    end
  end

  context 'using CDH 5 on Ubuntu 14.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 14.04) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
        node.default['hadoop']['distribution_version'] = '5.3.2'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'installs spark2-core package' do
      expect(chef_run).to install_package('spark2-core')
    end

    it 'installs spark2-python package' do
      expect(chef_run).to install_package('spark2-python')
    end

    it 'installs libgfortran3 package' do
      expect(chef_run).to install_package('libgfortran3')
    end
  end
end

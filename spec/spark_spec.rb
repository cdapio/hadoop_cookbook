require 'spec_helper'

describe 'hadoop::spark' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['spark']['release']['install'] = true
        node.default['spark']['spark_env']['spark_log_dir'] = '/data/log/spark'
        node.default['spark']['spark_site']['spark.eventLog.enabled'] = false
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'does not install spark-core package' do
      expect(chef_run).not_to install_package('spark-core')
    end

    it 'installs libgfortran package' do
      expect(chef_run).to install_package('libgfortran')
    end

    it 'creates Spark conf_dir' do
      expect(chef_run).to create_directory('/etc/spark/conf.chef').with(
        user: 'root',
        group: 'root'
      )
    end

    it 'deletes /var/log/spark' do
      expect(chef_run).to delete_directory('/var/log/spark')
    end

    it 'creates /data/log/spark' do
      expect(chef_run).to create_directory('/data/log/spark').with(
        mode: '0755'
      )
    end

    it 'creates /var/log/spark symlink' do
      link = chef_run.link('/var/log/spark')
      expect(link).to link_to('/data/log/spark')
    end

    %w(
      spark-env.sh
      spark-defaults.xml
    ).each do |file|
      it "creates #{file} from template" do
        expect(chef_run).to create_template("/etc/spark/conf.chef/#{file}")
      end
    end

    it 'runs execute[update spark-conf alternatives]' do
      expect(chef_run).to run_execute('update spark-conf alternatives')
    end
  end

  context 'using CDH 5 on Ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 12.04) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
        node.override['hadoop']['distribution_version'] = '5.3.2'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'installs spark-core package' do
      expect(chef_run).to install_package('spark-core')
    end

    it 'installs libgfortran3 package' do
      expect(chef_run).to install_package('libgfortran3')
    end
  end
end

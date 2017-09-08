require 'spec_helper'

describe 'hadoop::hive' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hive']['hive_site']['hive.exec.local.scratchdir'] = '/tmp/hive/scratch'
        node.default['hive']['hive_env']['hive_log_dir'] = '/data/log/hive'
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.3.4.7'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'installs hive package' do
      expect(chef_run).to install_package('hive_2_3_4_7_4')
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

    it 'deletes /etc/hive/conf directory' do
      expect(chef_run).to delete_directory('/etc/hive/conf')
    end

    it 'creates /tmp/hive/scratch directory' do
      expect(chef_run).to create_directory('/tmp/hive/scratch')
    end

    context 'using default hive.exec.local.scratchdir' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.automatic['domain'] = 'example.com'
          node.default['hive']['hive_env']['hive_log_dir'] = '/data/log/hive'
          stub_command(/test -L /).and_return(false)
          stub_command(/update-alternatives --display /).and_return(false)
        end.converge(described_recipe)
      end

      it 'does not create /tmp/hive directory' do
        expect(chef_run).not_to create_directory('/tmp/hive')
      end
    end

    context 'using /tmp/hive for hive.exec.local.scratchdir' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.default['hive']['hive_site']['hive.exec.local.scratchdir'] = '/tmp/hive'
          node.automatic['domain'] = 'example.com'
          stub_command(/test -L /).and_return(false)
          stub_command(/update-alternatives --display /).and_return(false)
        end.converge(described_recipe)
      end

      it 'creates /tmp/hive directory' do
        expect(chef_run).to create_directory('/tmp/hive')
      end
    end
  end

  context 'on Ubuntu 14.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 14.04) do |node|
        node.automatic['domain'] = 'example.com'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'installs hive package' do
      expect(chef_run).to install_package('hive')
    end
  end
end

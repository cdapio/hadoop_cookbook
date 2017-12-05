require 'spec_helper'

describe 'hadoop::hive2' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hive2']['hive_site']['hive.exec.local.scratchdir'] = '/tmp/hive2/scratch'
        node.default['hive2']['hive_env']['hive_log_dir'] = '/data/log/hive2'
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.6.0.3'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'installs hive2 package' do
      expect(chef_run).to install_package('hive2_2_6_0_3_8')
    end

    %w(/etc/hive2/conf.chef /var/lib/hive2).each do |dir|
      it "creates directory #{dir}" do
        expect(chef_run).to create_directory(dir)
      end
    end

    it 'does not execute execute[hive2-hdfs-homedir]' do
      expect(chef_run).not_to run_execute('hive2-hdfs-homedir')
    end

    it 'executes execute[update hive2-conf alternatives]' do
      expect(chef_run).to run_execute('update hive2-conf alternatives')
    end

    it 'creates hive2 HIVE_LOG_DIR' do
      expect(chef_run).to create_directory('/data/log/hive2').with(
        mode: '0755',
        user: 'hive',
        group: 'hive'
      )
    end

    it 'deletes /var/log/hive2' do
      expect(chef_run).to delete_directory('/var/log/hive2')
    end

    it 'creates /var/log/hive2 symlink' do
      link = chef_run.link('/var/log/hive2')
      expect(link).to link_to('/data/log/hive2')
    end

    %w(
      /etc/hive2/conf.chef/hive-site.xml
      /etc/hive2/conf.chef/hive-env.sh
    ).each do |template|
      it "creates #{template} template" do
        expect(chef_run).to create_template(template)
      end
    end

    it 'deletes /etc/hive2/conf directory' do
      expect(chef_run).to delete_directory('/etc/hive2/conf')
    end

    it 'creates /tmp/hive2/scratch directory' do
      expect(chef_run).to create_directory('/tmp/hive2/scratch')
    end

    context 'using default hive2.exec.local.scratchdir' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.automatic['domain'] = 'example.com'
          node.default['hive2']['hive_env']['hive_log_dir'] = '/data/log/hive2'
          stub_command(/test -L /).and_return(false)
          stub_command(/update-alternatives --display /).and_return(false)
        end.converge(described_recipe)
      end

      it 'does not create /tmp/hive2 directory' do
        expect(chef_run).not_to create_directory('/tmp/hive2')
      end
    end

    context 'using /tmp/hive2 for hive.exec.local.scratchdir' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.default['hive2']['hive_site']['hive.exec.local.scratchdir'] = '/tmp/hive2'
          node.automatic['domain'] = 'example.com'
          stub_command(/test -L /).and_return(false)
          stub_command(/update-alternatives --display /).and_return(false)
        end.converge(described_recipe)
      end

      it 'creates /tmp/hive2 directory' do
        expect(chef_run).to create_directory('/tmp/hive2')
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

    it 'installs hive2 package' do
      expect(chef_run).to install_package('hive2')
    end
  end
end

require 'spec_helper'

describe 'hadoop::storm' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.3.4.7'
        node.default['storm']['release']['install'] = false
        node.default['storm']['jaas']['client']['foo'] = 'bar'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'installs storm package' do
      expect(chef_run).to install_package('storm_2_3_4_7_4')
    end

    it 'creates /etc/storm/conf.chef/jaas.conf from template' do
      expect(chef_run).to create_template('/etc/storm/conf.chef/jaas.conf')
    end

    it 'deletes /etc/storm/conf directory' do
      expect(chef_run).to delete_directory('/etc/storm/conf')
    end

    it 'creates storm config directory' do
      expect(chef_run).to create_directory('/etc/storm/conf.chef').with(
        user: 'root',
        group: 'root',
        mode: '0755'
      )
    end

    it 'deletes rpm conf directory' do
      expect(chef_run).to delete_directory(%r{/usr/hdp/2.3.4.7-.*/storm/conf})
    end

    it 'creates storm config symlink' do
      link = chef_run.link(%r{/usr/hdp/2.3.4.7-.*/storm/conf})
      expect(link).to link_to('/etc/storm/conf.chef')
    end

    it 'creates storm config' do
      expect(chef_run).to create_template_if_missing('/etc/storm/conf.chef/storm.yaml').with(
        user: 'root',
        group: 'root',
        mode: '0644'
      )
    end

    it 'creates storm local directory' do
      expect(chef_run).to create_directory('/var/lib/storm').with(
        user: 'storm',
        group: 'storm',
        mode: '0700'
      )
    end

    it 'deletes rpm logs directory' do
      expect(chef_run).to delete_directory(%r{/usr/hdp/2.3.4.7-.*/storm/logs})
    end

    it 'creates storm logs directory' do
      expect(chef_run).to create_directory('/var/log/storm').with(
        user: 'storm',
        group: 'storm',
        mode: '0755'
      )
    end

    it 'creates storm logs symlink' do
      link = chef_run.link(%r{/usr/hdp/2.3.4.7-.*/storm/logs})
      expect(link).to link_to('/var/log/storm')
    end

    it 'creates storm environment ini' do
      expect(chef_run).to create_template('/etc/storm/conf.chef/storm_env.ini')
    end

    it 'runs execute[update storm-conf alternatives]' do
      expect(chef_run).to run_execute('update storm-conf alternatives')
    end
  end

  context 'on CentOS 6.9 tarball install' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
        node.default['hadoop']['distribution_version'] = '5.3.2'
        node.override['storm']['release']['install'] = true
        node.override['storm']['release']['install_path'] = '/opt'
        node.override['storm']['release']['version'] = '0.9.5'
        node.override['storm']['storm_conf']['storm.local.dir'] = '/data/lib/storm'
        node.override['storm']['storm_conf']['storm.log.dir'] = '/data/log/storm'
        stub_command(/test -L /).and_return(false)
        stub_command(/test -d /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'does not install storm package' do
      expect(chef_run).not_to install_package('storm')
    end

    it 'downloads a remote file' do
      expect(chef_run).to create_remote_file_if_missing('/opt/apache-storm-0.9.5.tar.gz')
    end

    it 'extracts the tarball' do
      expect(chef_run).to run_execute('install-storm-release')
    end

    it 'creates a symlink /opt/storm' do
      link = chef_run.link('/opt/storm')
      expect(link).to link_to('/opt/apache-storm-0.9.5')
    end

    it 'creates storm user' do
      expect(chef_run).to create_user('storm')
    end

    it 'creates storm group' do
      expect(chef_run).to create_group('storm')
    end

    it 'deletes extracted /opt/storm/conf directory' do
      expect(chef_run).to delete_directory('/opt/storm/conf')
    end

    it 'creates storm config directory' do
      expect(chef_run).to create_directory('/etc/storm/conf.chef').with(
        user: 'root',
        group: 'root',
        mode: '0755'
      )
    end

    it 'creates storm config symlink' do
      link = chef_run.link('/opt/storm/conf')
      expect(link).to link_to('/etc/storm/conf.chef')
    end

    it 'creates storm local directory' do
      expect(chef_run).to create_directory('/data/lib/storm').with(
        user: 'storm',
        group: 'storm',
        mode: '0700'
      )
    end

    it 'deletes extracted /opt/storm/logs directory' do
      expect(chef_run).to delete_directory('/opt/storm/logs')
    end

    it 'creates storm logs directory' do
      expect(chef_run).to create_directory('/data/log/storm').with(
        user: 'storm',
        group: 'storm',
        mode: '0755'
      )
    end

    it 'creates storm logs symlink' do
      link = chef_run.link('/opt/storm/logs')
      expect(link).to link_to('/data/log/storm')
    end

    it 'creates storm environment ini' do
      expect(chef_run).to create_template('/etc/storm/conf.chef/storm_env.ini')
    end

    it 'runs execute[update storm-conf alternatives]' do
      expect(chef_run).to run_execute('update storm-conf alternatives')
    end
  end
end

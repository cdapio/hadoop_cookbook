require 'spec_helper'

describe 'hadoop::oozie' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['oozie']['oozie_env']['oozie_log_dir'] = '/data/log/oozie'
        node.default['oozie']['oozie_site']['example_property'] = 'test'
        node.override['hadoop']['distribution'] = 'hdp'
        node.override['hadoop']['distribution_version'] = '2.3.4.7'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end
    name = 'oozie'
    pkg = 'oozie_2_3_4_7_4'

    it "does not install #{name} package" do
      expect(chef_run).not_to install_package(pkg)
    end

    it "runs package-#{pkg} ruby_block" do
      expect(chef_run).to run_ruby_block("package-#{pkg}")
    end

    it "creates #{name} service resource, but does not run it" do
      expect(chef_run).to_not disable_service(name)
      expect(chef_run).to_not enable_service(name)
      expect(chef_run).to_not reload_service(name)
      expect(chef_run).to_not restart_service(name)
      expect(chef_run).to_not start_service(name)
      expect(chef_run).to_not stop_service(name)
    end

    it 'creates oozie conf_dir' do
      expect(chef_run).to create_directory('/etc/oozie/conf.chef').with(
        user: 'root',
        group: 'root'
      )
    end

    %w(
      oozie-env.sh
      oozie-site.xml
    ).each do |file|
      it "creates #{file} from template" do
        expect(chef_run).to create_template("/etc/oozie/conf.chef/#{file}")
      end
    end

    it 'install unzip package' do
      expect(chef_run).to install_package('unzip')
    end

    it 'creates ext-2.2.zip file' do
      expect(chef_run).to create_remote_file_if_missing('/var/lib/oozie/ext-2.2.zip')
    end

    it 'does not run script[extract extjs into Oozie data directory]' do
      expect(chef_run).not_to run_script('extract extjs into Oozie data directory')
    end

    it 'deletes /var/log/oozie' do
      expect(chef_run).to delete_directory('/var/log/oozie')
    end

    it 'creates /data/log/oozie' do
      expect(chef_run).to create_directory('/data/log/oozie').with(
        mode: '0755'
      )
    end

    it 'creates /var/log/oozie symlink' do
      link = chef_run.link('/var/log/oozie')
      expect(link).to link_to('/data/log/oozie')
    end

    it 'runs execute[update oozie-conf alternatives]' do
      expect(chef_run).to run_execute('update oozie-conf alternatives')
    end
  end
end

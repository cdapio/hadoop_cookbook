require 'spec_helper'

describe 'hadoop::hadoop_kms' do
  context 'on CentOS 6.9 with CDH' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
        node.default['hadoop_kms']['kms_env']['kms_log'] = '/var/log/hadoop-kms'
        stub_command(/update-alternatives --display /).and_return(false)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
        stub_command(/test -L /).and_return(false)
      end.converge(described_recipe)
    end

    it 'installs hadoop-kms package' do
      expect(chef_run).to install_package('hadoop-kms')
    end

    it 'creates hadoop-kms conf_dir' do
      expect(chef_run).to create_directory('/etc/hadoop-kms/conf.chef').with(
        user: 'root',
        group: 'root'
      )
    end

    it 'creates /var/log/hadoop-kms' do
      expect(chef_run).to create_directory('/var/log/hadoop-kms').with(
        mode: '0755'
      )
    end

    %w(
      core-site.xml
      kms-acls.xml
      kms-env.sh
      kms-site.xml
      kms-log4j.properties
    ).each do |file|
      it "creates #{file} from template" do
        expect(chef_run).to create_template("/etc/hadoop-kms/conf.chef/#{file}")
      end
    end

    it 'runs execute[update hadoop-kms-conf alternatives]' do
      expect(chef_run).to run_execute('update hadoop-kms-conf alternatives')
    end
  end
end

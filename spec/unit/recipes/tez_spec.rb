require 'spec_helper'

describe 'hadoop::tez' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.3.4.7'
        stub_command('hdfs dfs -test -d hdfs://fauxhai.local/apps/tez').and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'install tez package' do
      expect(chef_run).to install_package('tez_2_3_4_7_4')
    end

    it 'does not executes execute[tez-hdfs-appdir]' do
      expect(chef_run).to_not run_execute('tez-hdfs-appdir')
    end

    it 'does not executes execute[hive-hdfs-appdir]' do
      expect(chef_run).to_not run_execute('hive-hdfs-appdir')
    end

    it 'executes execute[update tez-conf alternatives]' do
      expect(chef_run).to run_execute('update tez-conf alternatives')
    end

    it 'creates /etc/tez/conf.chef directory' do
      expect(chef_run).to create_directory('/etc/tez/conf.chef')
    end

    %w(/etc/tez/conf.chef/tez-site.xml /etc/tez/conf.chef/tez-env.sh).each do |template|
      it "creates #{template} template" do
        expect(chef_run).to create_template(template)
      end
    end
  end
end

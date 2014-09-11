require 'spec_helper'

describe 'hadoop::hive' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hive']['hive_site']['hive.exec.local.scratchdir'] = '/tmp'
        stub_command('update-alternatives --display hadoop-conf | grep best | awk \'{print $5}\' | grep /etc/hadoop/conf.chef').and_return(false)
        stub_command('update-alternatives --display hive-conf | grep best | awk \'{print $5}\' | grep /etc/hive/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    %w(mysql-connector-java postgresql-jdbc hive).each do |pkg|
      it "install #{pkg} package" do
        expect(chef_run).to install_package(pkg)
      end
    end

  end
end

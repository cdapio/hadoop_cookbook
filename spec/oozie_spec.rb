require 'spec_helper'

describe 'hadoop::oozie' do
  context 'on Centos 6.5 x86_64' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.5) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['oozie']['oozie_env']['oozie_log_dir'] = '/data/log/oozie'
        stub_command('test -L /var/log/oozie').and_return(false)
        stub_command('update-alternatives --display oozie-conf | grep best | awk \'{print $5}\' | grep /etc/oozie/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install oozie package' do
      expect(chef_run).to install_package('oozie')
    end
  end
end

require 'spec_helper'

describe 'hadoop::zookeeper_server' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.automatic['hostname'] = 'localhost'
        node.default['zookeeper']['zoocfg']['dataDir'] = '/var/lib/zookeeper'
        node.default['zookeeper']['zoocfg']['server.1'] = 'localhost:2181'
        stub_command('update-alternatives --display zookeeper-conf | grep best | awk \'{print $5}\' | grep /etc/zookeeper/conf.chef').and_return(false)
      end.converge(described_recipe)
    end

    it 'install zookeeper-server package' do
      expect(chef_run).to install_package('zookeeper-server')
    end

    it 'creates ZooKeeper conf_dir' do
      expect(chef_run).to create_directory('/etc/zookeeper/conf.chef').with(
        user: 'root',
        group: 'root'
      )
    end

    %w(/var/lib/zookeeper/myid /etc/zookeeper/conf.chef/log4j.properties /etc/zookeeper/conf.chef/zoo.cfg).each do |file|
      it "creates #{file} template" do
        expect(chef_run).to create_template(file)
      end
    end

    it 'renders file zoo.cfg with dataDir=/var/lib/zookeeper' do
      expect(chef_run).to render_file('/etc/zookeeper/conf.chef/zoo.cfg').with_content(
        %r{dataDir=/var/lib/zookeeper}
      )
    end

    it 'renders file myid with server.1=localhost:2181' do
      expect(chef_run).to render_file('/etc/zookeeper/conf.chef/zoo.cfg').with_content(
        /server.1=localhost:2181/
      )
    end

    it 'creates ZooKeeper dataDir' do
      expect(chef_run).to create_directory('/var/lib/zookeeper').with(
        user: 'zookeeper',
        group: 'zookeeper'
      )
    end

    it 'runs execute[update zookeeper-conf alternatives]' do
      expect(chef_run).to run_execute('update zookeeper-conf alternatives')
    end
  end
end

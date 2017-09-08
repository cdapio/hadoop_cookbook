require 'spec_helper'

describe 'hadoop::zookeeper_server' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.automatic['hostname'] = 'localhost'
        node.default['zookeeper']['zoocfg']['dataDir'] = '/var/lib/zookeeper'
        node.default['zookeeper']['zoocfg']['server.1'] = 'localhost:2181'
        node.default['zookeeper']['zookeeper_env']['zookeeper_log_dir'] = '/data/log/zookeeper'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end
    pkg = 'zookeeper-server'

    %W(
      /etc/default/#{pkg}
      /etc/init.d/#{pkg}
    ).each do |file|
      it "creates #{file} from template" do
        expect(chef_run).to create_template(file)
      end
    end

    it "creates #{pkg} service resource, but does not run it" do
      expect(chef_run.service(pkg)).to do_nothing
    end

    it 'creates zookeeper conf_dir' do
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

    it 'creates zookeeper group' do
      expect(chef_run).to create_group('zookeeper')
    end

    it 'manages zookeeper user' do
      expect(chef_run).to manage_user('zookeeper').with(
        shell: '/bin/bash'
      )
    end

    it 'creates zookeeper dataDir' do
      expect(chef_run).to create_directory('/var/lib/zookeeper').with(
        user: 'zookeeper',
        group: 'zookeeper'
      )
    end

    it 'creates zookeeper ZOOKEEPER_LOG_DIR' do
      expect(chef_run).to create_directory('/data/log/zookeeper').with(
        mode: '0755',
        user: 'zookeeper',
        group: 'zookeeper'
      )
    end

    it 'deletes /var/log/zookeeper' do
      expect(chef_run).to delete_directory('/var/log/zookeeper')
    end

    it 'creates /var/log/zookeeper symlink' do
      link = chef_run.link('/var/log/zookeeper')
      expect(link).to link_to('/data/log/zookeeper')
    end

    it 'creates /etc/zookeeper/conf.chef/zookeeper-env.sh template' do
      expect(chef_run).to create_template('/etc/zookeeper/conf.chef/zookeeper-env.sh')
    end

    it 'creates /var/lib/zookeeper/version-2 directory' do
      expect(chef_run).to create_directory('/var/lib/zookeeper/version-2')
    end

    it 'deletes /etc/zookeeper/conf directory' do
      expect(chef_run).to delete_directory('/etc/zookeeper/conf')
    end

    it 'runs execute[update zookeeper-conf alternatives]' do
      expect(chef_run).to run_execute('update zookeeper-conf alternatives')
    end
  end

  context 'on CentOS 6.9 with split dataDir/dataLogDir' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.automatic['hostname'] = 'localhost'
        node.default['zookeeper']['zoocfg']['dataLogDir'] = '/tmp/zk-logdir'
        stub_command(/test -L /).and_return(false)
        stub_command(/update-alternatives --display /).and_return(false)
      end.converge(described_recipe)
    end

    it 'creates /tmp/zk-logdir directory' do
      expect(chef_run).to create_directory('/tmp/zk-logdir')
    end

    it 'creates /tmp/zk-logdir/version-2 directory' do
      expect(chef_run).to create_directory('/tmp/zk-logdir/version-2')
    end
  end
end

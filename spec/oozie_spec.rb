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

    it 'install unzip package' do
      expect(chef_run).to install_package('unzip')
    end

    %w(mysql-connector-java postgresql-jdbc).each do |pkg|
      it "install #{pkg} package" do
        expect(chef_run).to install_package(pkg)
      end
      it "link #{pkg}.jar" do
        link = chef_run.link("/var/lib/oozie/#{pkg}.jar")
        expect(link).to link_to("/usr/share/java/#{pkg}.jar")
      end
    end

    it 'creates ext-2.2.zip file' do
      expect(chef_run).to create_remote_file_if_missing('/var/lib/oozie/ext-2.2.zip')
    end

    # script[extract extjs into Oozie data directory]   hadoop/recipes/oozie.rb:76
    # directory[/etc/oozie/conf.chef]    hadoop/recipes/oozie.rb:84
    # directory[/data/log/oozie]         hadoop/recipes/oozie.rb:116
    # directory[/var/log/oozie]          hadoop/recipes/oozie.rb:127
    # link[/var/log/oozie]               hadoop/recipes/oozie.rb:132
    # template[/etc/oozie/conf.chef/oozie-env.sh]   hadoop/recipes/oozie.rb:137
    # service[oozie]                     hadoop/recipes/oozie.rb:147
    # execute[update oozie-conf alternatives]   hadoop/recipes/oozie.rb:154

  end
end

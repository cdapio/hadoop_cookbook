require 'spec_helper'

describe 'hadoop::default' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
      end.converge(described_recipe)
    end

    it 'install hadoop-client package' do
      expect(chef_run).to install_package('hadoop-client')
    end

    it 'creates Hadoop conf_dir' do
      expect(chef_run).to create_directory('/etc/hadoop/conf.chef').with(
        user: 'root',
        group: 'root'
      )
    end

    it 'creates core-site.xml template' do
      expect(chef_run).to create_template('/etc/hadoop/conf.chef/core-site.xml')
    end

    it 'renders file core-site.xml with fs.defaultFS' do
      expect(chef_run).to render_file('/etc/hadoop/conf.chef/core-site.xml').with_content(
        /fs.defaultFS/
      )
    end
  end
end

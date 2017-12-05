require 'spec_helper'

describe 'hadoop::_sql_connectors' do
  context 'on CentOS 6.9' do
    context 'Using MySQL' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.default['hadoop']['sql_connector'] = 'mysql'
        end.converge(described_recipe)
      end

      it 'install mysql-connector-java package' do
        expect(chef_run).to install_package('mysql-connector-java')
      end
    end

    context 'using PostgreSQL' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.default['hadoop']['sql_connector'] = 'postgresql'
        end.converge(described_recipe)
      end

      it 'install postgresql-jdbc package' do
        expect(chef_run).to install_package('postgresql-jdbc')
      end
    end
  end

  context 'on Ubuntu 14.04' do
    context 'Using MySQL on CDH' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 14.04) do |node|
          node.default['hadoop']['sql_connector'] = 'mysql'
          node.override['hadoop']['distribution'] = 'cdh'
        end.converge(described_recipe)
      end

      it 'install libmysql-java package' do
        expect(chef_run).to install_package('libmysql-java')
      end
    end

    context 'Using PostgreSQL' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 14.04) do |node|
          node.default['hadoop']['sql_connector'] = 'postgresql'
        end.converge(described_recipe)
      end

      it 'install libpostgresql-jdbc-java package' do
        expect(chef_run).to install_package('libpostgresql-jdbc-java')
      end
    end
  end
end

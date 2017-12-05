require 'spec_helper'

describe 'hadoop::parquet' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
      end.converge(described_recipe)
    end

    it 'does not install parquet-format package' do
      expect(chef_run).not_to install_package('parquet-format')
    end

    context 'using CDH 5' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.override['hadoop']['distribution'] = 'cdh'
          node.default['hadoop']['distribution_version'] = '5.3.2'
          node.automatic['domain'] = 'example.com'
        end.converge(described_recipe)
      end

      it 'installs parquet-format package' do
        expect(chef_run).to install_package('parquet-format')
      end
    end
  end
end

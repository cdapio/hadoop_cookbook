require 'spec_helper'

describe 'hadoop::pig' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.3.4.7'
      end.converge(described_recipe)
    end

    it 'install pig package' do
      expect(chef_run).to install_package('pig_2_3_4_7_4')
    end
  end
end

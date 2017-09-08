require 'spec_helper'

describe 'hadoop::slider' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['distribution'] = 'hdp'
        node.override['hadoop']['distribution_version'] = '2.6.0.3'
      end.converge(described_recipe)
    end
    pkg = 'slider_2_6_0_3_8'

    it "installs #{pkg} package" do
      expect(chef_run).to install_package(pkg)
    end
  end
end

require 'spec_helper'

describe 'hadoop::_compression_libs' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6).converge(described_recipe)
    end

    %w(snappy snappy-devel lzo lzo-devel hadooplzo hadooplzo-native).each do |pkg|
      it "installs #{pkg} package" do
        expect(chef_run).to install_package(pkg)
      end
    end
  end

  context 'using CDH' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.override['hadoop']['distribution'] = 'cdh'
        node.override['hadoop']['distribution_version'] = '5.4.1'
      end.converge(described_recipe)
    end

    %w(snappy snappy-devel).each do |pkg|
      it "installs #{pkg} package" do
        expect(chef_run).to install_package(pkg)
      end
    end

    %w(lzo lzo-devel hadooplzo hadooplzo-native).each do |pkg|
      it "does not install #{pkg} package" do
        expect(chef_run).not_to install_package(pkg)
      end
    end
  end

  context 'on Ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 12.04).converge(described_recipe)
    end

    %w(libsnappy1 libsnappy1-dev liblzo2-2 liblzo2-dev hadooplzo).each do |pkg|
      it "installs #{pkg} package" do
        expect(chef_run).to install_package(pkg)
      end
    end
  end

  context 'using CDH' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 12.04) do |node|
        node.override['hadoop']['distribution'] = 'cdh'
        node.override['hadoop']['distribution_version'] = '5.4.1'
      end.converge(described_recipe)
    end

    %w(libsnappy1 libsnappy1-dev).each do |pkg|
      it "installs #{pkg} package" do
        expect(chef_run).to install_package(pkg)
      end
    end

    %w(liblzo2-2 liblzo2-dev hadooplzo).each do |pkg|
      it "does not install #{pkg} package" do
        expect(chef_run).not_to install_package(pkg)
      end
    end
  end
end

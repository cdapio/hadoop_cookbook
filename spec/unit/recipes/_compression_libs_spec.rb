require 'spec_helper'

describe 'hadoop::_compression_libs' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.override['hadoop']['distributon'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.3.4.7'
      end.converge(described_recipe)
    end

    %w(snappy snappy-devel lzo lzo-devel hadooplzo hadooplzo-native).each do |pkg|
      it "installs #{pkg} package" do
        expect(chef_run).to install_package(pkg)
      end
    end

    context 'using HDP 2.1.15.0' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.default['hadoop']['distribution'] = 'hdp'
          node.default['hadoop']['distribution_version'] = '2.1.15.0'
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

    context 'using CDH' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
          node.override['hadoop']['distribution'] = 'cdh'
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
  end

  context 'on Ubuntu 14.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 14.04) do |node|
        node.default['hadoop']['distribution'] = 'hdp'
        node.default['hadoop']['distribution_version'] = '2.3.4.7'
      end.converge(described_recipe)
    end

    %w(libsnappy1 libsnappy-dev liblzo2-2 liblzo2-dev hadooplzo).each do |pkg|
      it "installs #{pkg} package" do
        expect(chef_run).to install_package(pkg)
      end
    end

    context 'using HDP 2.1.15.0' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 14.04) do |node|
          node.default['hadoop']['distribution'] = 'hdp'
          node.default['hadoop']['distribution_version'] = '2.1.15.0'
        end.converge(described_recipe)
      end

      %w(libsnappy1 libsnappy-dev).each do |pkg|
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

    context 'using CDH' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 14.04) do |node|
          node.override['hadoop']['distribution'] = 'cdh'
        end.converge(described_recipe)
      end

      %w(libsnappy1 libsnappy-dev).each do |pkg|
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
end

require 'spec_helper'

describe 'hadoop::repo' do
  context 'on CentOS 6.9' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
      end.converge(described_recipe)
    end

    %w(Updates-HDP-2.x HDP-UTILS-1.1.0.21).each do |repo|
      it "add #{repo} yum_repository" do
        expect(chef_run).to add_yum_repository(repo)
      end
    end
  end

  context 'using HDP GA release' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution_version'] = '2.2.0.0'
      end.converge(described_recipe)
    end

    %w(HDP-2.x HDP-UTILS-1.1.0.21).each do |repo|
      it "add #{repo} yum_repository" do
        expect(chef_run).to add_yum_repository(repo)
      end
    end
  end

  context 'using CDH 5' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
        node.override['hadoop']['distribution_version'] = '5.4.2'
      end.converge(described_recipe)
    end

    it 'adds cloudera-cdh5 yum_repository' do
      expect(chef_run).to add_yum_repository('cloudera-cdh5')
    end
  end

  context 'using IOP' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'iop'
        node.override['hadoop']['distribution_version'] = '4.1.0.0'
      end.converge(described_recipe)
    end

    %w(IOP-4.1.x IOP-UTILS-1.2.0.0).each do |repo|
      it "add #{repo} yum_repository" do
        expect(chef_run).to add_yum_repository(repo)
      end
    end
  end

  context 'on Ubuntu 14.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 14.04) do |node|
        node.automatic['domain'] = 'example.com'
      end.converge(described_recipe)
    end

    %w(hdp hdp-utils).each do |repo|
      it "add #{repo} apt_repository" do
        expect(chef_run).to add_apt_repository(repo)
      end
    end

    it 'add hdp apt_preference' do
      expect(chef_run).to add_apt_preference('hdp')
    end
  end

  context 'using CDH 5' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 14.04) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
      end.converge(described_recipe)
    end

    it 'adds cloudera-cdh5 apt_repository' do
      expect(chef_run).to add_apt_repository('cloudera-cdh5')
    end

    it 'add cloudera-cdh5 apt_preference' do
      expect(chef_run).to add_apt_preference('cloudera-cdh5')
    end
  end
end

require 'spec_helper'

describe 'hadoop::repo' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
      end.converge(described_recipe)
    end

    %w(HDP-2.x Updates-HDP-2.x HDP-UTILS-1.1.0.20).each do |repo|
      it "add #{repo} yum_repository" do
        expect(chef_run).to add_yum_repository(repo)
      end
    end
  end

  context 'using CDH 5' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['hadoop']['distribution'] = 'cdh'
      end.converge(described_recipe)
    end

    it 'adds cloudera-cdh5 yum_repository' do
      expect(chef_run).to add_yum_repository('cloudera-cdh5')
    end
  end
  context 'on Ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 12.04) do |node|
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
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 12.04) do |node|
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

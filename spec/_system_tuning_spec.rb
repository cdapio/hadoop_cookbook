require 'spec_helper'

describe 'hadoop::_system_tuning' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do
        allow(::File).to receive_messages(:file? => true)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
      end.converge(described_recipe)
    end

    it 'disables swap' do
      expect(chef_run).to apply_sysctl_param('vm.swappiness')
    end

    it 'disables transparent hugepage compaction' do
      expect(chef_run).to run_execute('disable-transparent-hugepage-compaction')
    end
  end

  context 'on Ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 12.04) do
        allow(::File).to receive_messages(:file? => true)
        stub_command(%r{/sys/kernel/mm/(.*)transparent_hugepage/defrag}).and_return(false)
      end.converge(described_recipe)
    end

    it 'disables transparent hugepage compaction' do
      expect(chef_run).to run_execute('disable-transparent-hugepage-compaction')
    end
  end
end

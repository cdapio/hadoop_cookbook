require File.expand_path('../support/helpers', __FILE__)

describe 'hadoop::hbase' do

  include Helpers::Hadoop

  # Example spec tests can be found at http://git.io/Fahwsw
  it 'creates hbase conf dir' do
    directory("/etc/hbase/#{node['hbase']['conf_dir']}")
      .must_exist
      .with(:owner, 'root')
      .and(:group, 'root')
      .and(:mode, '0755')
  end

  it 'ensures alternatives link' do
    link('/etc/hbase/conf')
      .must_exist
      .with(:link_type, :symbolic)
      .and(:to, '/etc/alternatives/hbase-conf')
    link('/etc/alternatives/hbase-conf')
      .must_exist
      .with(:link_type, :symbolic)
      .and(:to, "/etc/hbase/#{node['hbase']['conf_dir']}")
  end

  it 'creates hbase config files' do
    %w(hbase_policy hbase_site).each do |sitefile|
      next unless node['hbase'].key? sitefile
      file("/etc/hbase/#{node['hbase']['conf_dir']}/#{sitefile.gsub('_', '-')}.xml")
        .must_exist
        .with(:owner, 'root')
        .and(:group, 'root')
        .and(:mode, '0644')
    end
  end

end

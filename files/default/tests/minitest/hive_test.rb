require File.expand_path('../support/helpers', __FILE__)

describe 'hadoop::hive' do

  include Helpers::Hadoop

  # Example spec tests can be found at http://git.io/Fahwsw
  it 'creates hive conf dir' do
    directory("/etc/hive/#{node['hive']['conf_dir']}")
      .must_exist
      .with(:owner, 'root')
      .and(:group, 'root')
      .and(:mode, '0755')
  end

  it 'creates /var/lib/hive dir' do
    directory('/var/lib/hive')
      .must_exist
      .with(:owner, 'hive')
      .and(:group, 'hive')
      .and(:mode, '0755')
  end

  it 'ensures alternatives link' do
    link('/etc/hive/conf')
      .must_exist
      .with(:link_type, :symbolic)
      .and(:to, '/etc/alternatives/hive-conf')
    link('/etc/alternatives/hive-conf')
      .must_exist
      .with(:link_type, :symbolic)
      .and(:to, "/etc/hive/#{node['hive']['conf_dir']}")
  end

  it 'creates hive config files' do
    %w(hive_site).each do |sitefile|
      next unless node['hive'].key? sitefile
      file("/etc/hive/#{node['hive']['conf_dir']}/#{sitefile.gsub('_', '-')}.xml")
        .must_exist
        .with(:owner, 'root')
        .and(:group, 'root')
        .and(:mode, '0644')
    end
  end

end

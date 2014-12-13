require File.expand_path('../support/helpers', __FILE__)

describe 'hadoop::zookeeper_server' do
  include Helpers::Hadoop

  # Example spec tests can be found at http://git.io/Fahwsw
  it 'creates zookeeper conf dir' do
    directory("/etc/zookeeper/#{node['zookeeper']['conf_dir']}")
      .must_exist
      .with(:owner, 'root')
      .and(:group, 'root')
      .and(:mode, '0755')
  end

  it 'ensures alternatives link' do
    link('/etc/zookeeper/conf')
      .must_exist
      .with(:link_type, :symbolic)
      .and(:to, '/etc/alternatives/zookeeper-conf')
    link('/etc/alternatives/zookeeper-conf')
      .must_exist
      .with(:link_type, :symbolic)
      .and(:to, "/etc/zookeeper/#{node['zookeeper']['conf_dir']}")
  end

  it 'creates zookeeper config files' do
    file("/etc/zookeeper/#{node['zookeeper']['conf_dir']}/zoo.cfg")
      .must_exist
      .with(:owner, 'root')
      .and(:group, 'root')
      .and(:mode, '0644')
  end
end

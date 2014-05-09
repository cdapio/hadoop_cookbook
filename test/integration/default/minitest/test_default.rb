require 'minitest/autorun'

describe 'hadoop::default' do

  it 'creates hadoop conf dir' do
    directory("/etc/hadoop/#{node['hadoop']['conf_dir']}")
      .must_exist
      .with(:owner, 'root')
      .and(:group, 'root')
      .and(:mode, '0755')
  end

  it 'ensures alternatives link' do
    link('/etc/hadoop/conf')
      .must_exist
      .with(:link_type, :symbolic)
      .and(:to, '/etc/alternatives/hadoop-conf')
    link('/etc/alternatives/hadoop-conf')
      .must_exist
      .with(:link_type, :symbolic)
      .and(:to, "/etc/hadoop/#{node['hadoop']['conf_dir']}")
  end

  it 'creates hadoop config files' do
    %w(capacity_scheduler core_site hadoop_policy hdfs_site mapred_site yarn_site).each do |sitefile|
      if node['hadoop'].key? sitefile
        file("/etc/hadoop/#{node['hadoop']['conf_dir']}/#{sitefile.gsub('_', '-')}.xml")
          .must_exist
          .with(:owner, 'root')
          .and(:group, 'root')
          .and(:mode, '0644')
      end
    end
  end

end

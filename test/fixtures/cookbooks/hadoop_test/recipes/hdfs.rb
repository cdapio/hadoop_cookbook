include_recipe 'hadoop::hadoop_hdfs_namenode'
include_recipe 'hadoop::hadoop_hdfs_datanode'

include_recipe 'hadoop_test::systemd_reload'

ruby_block 'Format and start HDFS' do
  block do
    true
  end
  notifies :run, 'execute[systemd-daemon-reload]', :immediately if
    (node['platform_family'] == 'rhel' && node['platform_version'].to_i >= 7) ||
    (node['platform'] == 'ubuntu' && node['platform_version'].to_i >= 16) ||
    (node['platform'] == 'debian' && node['platform_version'].to_i >= 8)
  notifies :run, 'execute[hdfs-namenode-format]', :immediately
  notifies :start, 'service[hadoop-hdfs-namenode]', :immediately
  notifies :start, 'service[hadoop-hdfs-datanode]', :immediately
end

require File.expand_path('../support/helpers', __FILE__)

describe 'hadoop::hadoop_hdfs_datanode' do

  include Helpers::Hadoop

  it 'ensures HDFS data dirs exist' do
    node['hadoop']['hdfs_site']['dfs.datanode.data.dir'].split(',').each do |dir|
      directory(dir.gsub('file://', ''))
      .must_exist
      .with(:owner, 'hdfs')
      .and(:group, 'hdfs')
      .and(:mode, node['hadoop']['hdfs_site']['dfs.datanode.data.dir.perm'])
    end
  end

end

require File.expand_path('../support/helpers', __FILE__)

describe 'hadoop::hadoop_hdfs_secondarynamenode' do

  include Helpers::Hadoop

  it 'ensures HDFS checkpoint dirs exist' do
    node['hadoop']['hdfs_site']['dfs.namenode.checkpoint.dir'].split(',').each do |dir|
      directory(dir.gsub('file://', ''))
      .must_exist
      .with(:owner, 'hdfs')
      .and(:group, 'hdfs')
      .and(:mode, '0700')
    end
  end

  it 'ensures HDFS checkpoint edits dirs exist' do
    node['hadoop']['hdfs_site']['dfs.namenode.checkpoint.edits.dir'].split(',').each do |dir|
      directory(dir.gsub('file://', ''))
      .must_exist
      .with(:owner, 'hdfs')
      .and(:group, 'hdfs')
      .and(:mode, '0700')
    end
  end

end

require File.expand_path('../support/helpers', __FILE__)

describe 'hadoop::hadoop_hdfs_namenode' do

  include Helpers::Hadoop

  it 'ensures HDFS name dirs exist' do
    node['hadoop']['hdfs_site']['dfs.namenode.name.dir'].split(',').each do |dir|
      directory(dir.gsub('file://', ''))
      .must_exist
      .with(:owner, 'hdfs')
      .and(:group, 'hdfs')
      .and(:mode, '0700')
    end
  end

end

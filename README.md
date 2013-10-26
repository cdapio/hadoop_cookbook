# hadoop cookbook

# Requirements

# Usage

# Attributes

## Distribution Attributes

* `['hadoop']['distribution']` - Specifies which Hadoop distribution to use, currently supported: hdp. Default `hdp`
* `['hadoop']['yum_repo_url']` - Provide an alternate yum installation source location. If you change this attribute, you are expected to provide a path to a working repo for the `node['hadoop']['distribution']` used. Default: `nil`
* `['hadoop']['yum_repo_key_url']` - Provide an alternative yum repository key source location. Default `nil`

## Global Configuration Attributes

* `['hadoop']['conf_dir']` - The directory used inside `/etc/hadoop` and used via the alternatives system. Default `conf.chef`

# Recipes

* `default.rb` - Sets up configuration and `hadoop-client` packages.
* `hadoop_hdfs_datanode` - Sets up an HDFS datanode.
* `repo` - Sets up package manager repositories for specified `node['hadoop']['distribution']`

# Author

Author:: Chris Gianelloni (<chris@continuuity.com>)

Author:: Continuuity, Inc. (<ops@continuuity.com>)

# Testing

This cookbook requires the `vagrant-omnibus` and `vagrant-berkshelf` Vagrant plugins to be installed.

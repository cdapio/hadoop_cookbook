# hadoop cookbook

# Requirements

# Usage

# Attributes

## Distribution Attributes

* `['hadoop']['distribution']` - Specifies which Hadoop distribution to use, currently supported: hdp. Default `hdp`
* `['hadoop']['yum_repo_url']` - Provide an alternate yum installation source location. If you change this attribute, you are expected to provide a path to a working repo for the `node['hadoop']['distribution']` used. Default: `nil`
* `['hadoop']['yum_repo_key_url']` - Provide an alternative yum repository key source location. Default `nil`

# Recipes

# Author

Author:: Continuuity, Inc. (<ops@continuuity.com>)

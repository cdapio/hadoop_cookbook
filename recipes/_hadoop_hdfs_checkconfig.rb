#
# Cookbook Name:: hadoop
# Recipe:: _hadoop_hdfs_checkconfig
#
# Copyright © 2013-2015 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# For HDFS functionality, we require fs.defaultFS property to be set
if node['hadoop'].key?('core_site') && node['hadoop']['core_site'].key?('fs.defaultFS')
  Chef::Log.info("HDFS NameNode configured at #{node['hadoop']['core_site']['fs.defaultFS']}")
else
  Chef::Application.fatal!("HDFS NameNode must be configured! Set default['hadoop']['core_site']['fs.defaultFS'] to the NameNode.")
end

#
# Cookbook Name:: hadoop
# Provider:: file
#
# Copyright © 2015-2016 Cask Data, Inc.
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

use_inline_resources if defined?(use_inline_resources)
include Hadoop::Hdfs

action :create do
end

action :create_if_empty do
end

action :delete do
  if Hadoop::Hdfs.file?(new_resource.path)
    converge_by("delete HDFS file #{new_resource.path}") do
      Hadoop::Hdfs.delete("#{new_resource.namenode}/#{new_resource.path}")
      Chef::Log.info("#{new_resource} deleted file at #{new_resource.path} on #{new_resource.namenode}")
    end
  elsif Hadoop::Hdfs.exist?(new_resource.path)
    Chef::Application.fatal!("#{new_resource} on #{new_resource.namenode} is not an HDFS file!")
  end
end

action :touch do
end

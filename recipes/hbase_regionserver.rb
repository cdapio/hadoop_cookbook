#
# Cookbook Name:: hadoop
# Recipe:: hbase_regionserver
#
# Copyright (C) 2013-2014 Continuuity, Inc.
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

include_recipe 'hadoop::hbase'
include_recipe 'hadoop::hbase_checkconfig'

package 'hbase-regionserver' do
  action :install
end

service 'hbase-regionserver' do
  supports [:restart => true, :reload => false, :status => true]
  # cdh4.4 init scripts do not return non-zero exit codes for status
  status_command 'service hbase-regionserver status | grep -v "not running"'
  action :nothing
end

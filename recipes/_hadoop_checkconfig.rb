#
# Cookbook Name:: hadoop
# Recipe:: _hadoop_checkconfig
#
# Copyright © 2015 Cask Data, Inc.
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

# When using the Fair Scheduler, we must have a configuration
if node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?('yarn.resourcemanager.scheduler.class') && \
   node['hadoop']['yarn_site']['yarn.resourcemanager.scheduler.class'] == \
   'org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler'
  unless node['hadoop'].key?('fair_scheduler') && !node['hadoop']['fair_scheduler'].empty?
    Chef::Application.fatal!('Cannot set YARN scheduler to fair-scheduler without configuring it!')
  end
end

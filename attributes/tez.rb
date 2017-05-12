#
# Cookbook:: hadoop
# Attribute:: tez
#
# Copyright © 2013-2016 Cask Data, Inc.
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

default['tez']['tez_env']['tez_conf_dir'] = "/etc/tez/#{node['tez']['conf_dir']}"
default['tez']['tez_env']['tez_jars'] = '/usr/lib/tez/*:/usr/lib/tez/lib/*'
default['tez']['tez_site']['tez.lib.uris'] = '${fs.defaultFS}/apps/tez/,${fs.defaultFS}/apps/tez/lib/'

if node['hadoop']['distribution'] == 'hdp' && node['hadoop']['distribution_version'].to_f >= 2.2
  default['tez']['tez_env']['tez_jars'] = '/usr/hdp/current/tez-client/*:/usr/hdp/current/tez-client/lib/*'
  default['tez']['tez_site']['tez.lib.uris'] = '${fs.defaultFS}/hdp/apps/${hdp.version}/tez/tez.tar.gz'
end

default['hadoop']['hadoop_env']['hadoop_classpath'] =
  if node['hadoop'].key?('hadoop_env') && node['hadoop']['hadoop_env'].key?('hadoop_classpath')
    "$HADOOP_CLASSPATH:#{default['hadoop']['hadoop_env']['hadoop_classpath']}:#{node['tez']['tez_env']['tez_conf_dir']}:#{node['tez']['tez_env']['tez_jars']}"
  else
    "$HADOOP_CLASSPATH:#{node['tez']['tez_env']['tez_conf_dir']}:#{node['tez']['tez_env']['tez_jars']}"
  end

#
# Cookbook Name:: hadoop
# Provider:: directory
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

# NOTES:
# $ hdfs dfs -ls /tmp/chef-hello.txt
# Found 1 items
# -rw-r--r--   2 hdfs supergroup         45 2014-01-16 22:53 /tmp/chef-hello.txt
# $ echo $?
# 0
# $ hdfs dfs -ls /tmp/nofile.txt
# ls: `/tmp/nofile.txt': No such file or directory
# $ echo $?
# 1
# $ hdfs dfs -ls / | grep tmp
# drwxrwxrwt   - hdfs  supergroup          0 2014-04-01 20:39 /tmp

use_inline_resources if defined?(use_inline_resources)
include Hadoop::Hdfs

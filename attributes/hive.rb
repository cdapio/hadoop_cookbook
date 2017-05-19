#
# Cookbook:: hadoop
# Attribute:: hive
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

# hive-site.xml
default['hive']['hive_site']['hive.metastore.uris'] = 'thrift://localhost:9083'
default['hive']['hive_site']['javax.jdo.option.ConnectionURL'] = 'jdbc:derby:;databaseName=/var/lib/hive/metastore/metastore_db;create=true'
default['hive']['hive_site']['javax.jdo.option.ConnectionDriverName'] = 'org.apache.derby.jdbc.EmbeddedDriver'

# hive-exec-log4j.properties
default['hive']['hive_exec_log4j']['hive.log.threshold'] = 'ALL'
default['hive']['hive_exec_log4j']['hive.root.logger'] = 'INFO,FA'
default['hive']['hive_exec_log4j']['hive.log.dir'] = '${java.io.tmpdir}/${user.name}'
default['hive']['hive_exec_log4j']['hive.query.id'] = 'hadoop'
default['hive']['hive_exec_log4j']['hive.log.file'] = '${hive.query.id}.log'
default['hive']['hive_exec_log4j']['log4j.rootLogger'] = '${hive.root.logger}, EventCounter'
default['hive']['hive_exec_log4j']['log4j.threshhold'] = '${hive.log.threshold}'
default['hive']['hive_exec_log4j']['log4j.appender.FA'] = 'org.apache.log4j.FileAppender'
default['hive']['hive_exec_log4j']['log4j.appender.FA.File'] = '${hive.log.dir}/${hive.log.file}'
default['hive']['hive_exec_log4j']['log4j.appender.FA.layout'] = 'org.apache.log4j.PatternLayout'
default['hive']['hive_exec_log4j']['log4j.appender.FA.layout.ConversionPattern'] = '%d{ISO8601} %-5p [%t]: %c{2} (%F:%M(%L)) - %m%n'
default['hive']['hive_exec_log4j']['log4j.appender.console'] = 'org.apache.log4j.ConsoleAppender'
default['hive']['hive_exec_log4j']['log4j.appender.console.target'] = 'System.err'
default['hive']['hive_exec_log4j']['log4j.appender.console.layout'] = 'org.apache.log4j.PatternLayout'
default['hive']['hive_exec_log4j']['log4j.appender.console.layout.ConversionPattern'] = '%d{yy/MM/dd HH:mm:ss} [%t] %p %c{2}: %m%n'
default['hive']['hive_exec_log4j']['log4j.appender.EventCounter'] = 'org.apache.hadoop.hive.shims.HiveEventCounter'
default['hive']['hive_exec_log4j']['log4j.category.DataNucleus'] = 'ERROR,FA'
default['hive']['hive_exec_log4j']['log4j.category.Datastore'] = 'ERROR,FA'
default['hive']['hive_exec_log4j']['log4j.category.Datastore.Schema'] = 'ERROR,FA'
default['hive']['hive_exec_log4j']['log4j.category.JPOX.Datastore'] = 'ERROR,FA'
default['hive']['hive_exec_log4j']['log4j.category.JPOX.Plugin'] = 'ERROR,FA'
default['hive']['hive_exec_log4j']['log4j.category.JPOX.MetaData'] = 'ERROR,FA'
default['hive']['hive_exec_log4j']['log4j.category.JPOX.Query'] = 'ERROR,FA'
default['hive']['hive_exec_log4j']['log4j.category.JPOX.General'] = 'ERROR,FA'
default['hive']['hive_exec_log4j']['log4j.category.JPOX.Enhancer'] = 'ERROR,FA'
default['hive']['hive_exec_log4j']['log4j.logger.org.apache.zookeeper.server.NIOServerCnxn'] = 'WARN,FA'
default['hive']['hive_exec_log4j']['log4j.logger.org.apache.zookeeper.ClientCnxnSocketNIO'] = 'WARN,FA'

# hive-log4j.properties
default['hive']['hive_log4j']['hive.log.threshold'] = 'ALL'
default['hive']['hive_log4j']['hive.root.logger'] = 'WARN,DRFA'
default['hive']['hive_log4j']['hive.log.dir'] = '${java.io.tmpdir}/${user.name}'
default['hive']['hive_log4j']['hive.log.file'] = 'hive.log'
default['hive']['hive_log4j']['log4j.rootLogger'] = '${hive.root.logger}, EventCounter'
default['hive']['hive_log4j']['log4j.threshold'] = '${hive.log.threshold}'
default['hive']['hive_log4j']['log4j.appender.DRFA'] = 'org.apache.log4j.DailyRollingFileAppender'
default['hive']['hive_log4j']['log4j.appender.DRFA.File'] = '${hive.log.dir}/${hive.log.file}'
default['hive']['hive_log4j']['log4j.appender.DRFA.DatePattern'] = '.yyyy-MM-dd'
# default['hive']['hive_log4j']['log4j.appender.DRFA.MaxBackupIndex'] = '30'
default['hive']['hive_log4j']['log4j.appender.DRFA.layout'] = 'org.apache.log4j.PatternLayout'
default['hive']['hive_log4j']['log4j.appender.DRFA.layout.ConversionPattern'] = '%d{ISO8601} %-5p [%t]: %c{2} (%F:%M(%L)) - %m%n'
default['hive']['hive_log4j']['log4j.appender.console'] = 'org.apache.log4j.ConsoleAppender'
default['hive']['hive_log4j']['log4j.appender.console.target'] = 'System.err'
default['hive']['hive_log4j']['log4j.appender.console.layout'] = 'org.apache.log4j.PatternLayout'
default['hive']['hive_log4j']['log4j.appender.console.layout.ConversionPattern'] = '%d{yy/MM/dd HH:mm:ss} [%t]: %p %c{2}: %m%n'
default['hive']['hive_log4j']['log4j.appender.console.encoding'] = 'UTF-8'
default['hive']['hive_log4j']['log4j.appender.EventCounter'] = 'org.apache.hadoop.hive.shims.HiveEventCounter'
default['hive']['hive_log4j']['log4j.category.DataNucleus'] = 'ERROR,DRFA'
default['hive']['hive_log4j']['log4j.category.Datastore'] = 'ERROR,DRFA'
default['hive']['hive_log4j']['log4j.category.Datastore.Schema'] = 'ERROR,DRFA'
default['hive']['hive_log4j']['log4j.category.JPOX.Datastore'] = 'ERROR,DRFA'
default['hive']['hive_log4j']['log4j.category.JPOX.Plugin'] = 'ERROR,DRFA'
default['hive']['hive_log4j']['log4j.category.JPOX.MetaData'] = 'ERROR,DRFA'
default['hive']['hive_log4j']['log4j.category.JPOX.Query'] = 'ERROR,DRFA'
default['hive']['hive_log4j']['log4j.category.JPOX.General'] = 'ERROR,DRFA'
default['hive']['hive_log4j']['log4j.category.JPOX.Enhancer'] = 'ERROR,DRFA'
default['hive']['hive_log4j']['log4j.logger.org.apache.zookeeper.server.NIOServerCnxn'] = 'WARN,DRFA'
default['hive']['hive_log4j']['log4j.logger.org.apache.zookeeper.ClientCnxnSocketNIO'] = 'WARN,DRFA'
default['hive']['hive_log4j']['log4j.logger.org.apache.hadoop.hive.ql.parse.SemanticAnalyzer'] = 'INFO'
default['hive']['hive_log4j']['log4j.logger.org.apache.hadoop.hive.ql.Driver'] = 'INFO'
default['hive']['hive_log4j']['log4j.logger.org.apache.hadoop.hive.ql.exec.mr.ExecDriver'] = 'INFO'
default['hive']['hive_log4j']['log4j.logger.org.apache.hadoop.hive.ql.exec.mr.MapRedTask'] = 'INFO'
default['hive']['hive_log4j']['log4j.logger.org.apache.hadoop.hive.ql.exec.mr.MapredLocalTask'] = 'INFO'
default['hive']['hive_log4j']['log4j.logger.org.apache.hadoop.hive.ql.exec.Task'] = 'INFO'
default['hive']['hive_log4j']['log4j.logger.org.apache.hadoop.hive.ql.session.SessionState'] = 'INFO'

#
# Cookbook:: hadoop
# Attribute:: kms
#
# Copyright © 2016 Cask Data, Inc.
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

# KMS ACLs
default['hadoop_kms']['kms_acls']['hadoop.kms.acl.CREATE'] = '*'
default['hadoop_kms']['kms_acls']['hadoop.kms.acl.DELETE'] = '*'
default['hadoop_kms']['kms_acls']['hadoop.kms.acl.ROLLOVER'] = '*'
default['hadoop_kms']['kms_acls']['hadoop.kms.acl.GET'] = '*'
default['hadoop_kms']['kms_acls']['hadoop.kms.acl.GET_KEYS'] = '*'
default['hadoop_kms']['kms_acls']['hadoop.kms.acl.GET_METADATA'] = '*'
default['hadoop_kms']['kms_acls']['hadoop.kms.acl.SET_KEY_MATERIAL'] = '*'
default['hadoop_kms']['kms_acls']['hadoop.kms.acl.GENERATE_EEK'] = '*'
default['hadoop_kms']['kms_acls']['hadoop.kms.acl.DECRYPT_EEK'] = '*'
default['hadoop_kms']['kms_acls']['default.key.acl.MANAGEMENT'] = '*'
default['hadoop_kms']['kms_acls']['default.key.acl.GENERATE_EEK'] = '*'
default['hadoop_kms']['kms_acls']['default.key.acl.DECRYPT_EEK'] = '*'
default['hadoop_kms']['kms_acls']['default.key.acl.READ'] = '*'

# Default kms-site.xml
default['hadoop_kms']['kms_site']['hadoop.kms.cache.enable'] = 'true'

# Default Logging options
default['hadoop_kms']['log4j']['log4j.appender.kms'] = 'org.apache.log4j.DailyRollingFileAppender'
default['hadoop_kms']['log4j']['log4j.appender.kms.DatePattern'] = '.yyyy-MM-dd'
default['hadoop_kms']['log4j']['log4j.appender.kms.File'] = '${kms.log.dir}/kms.log'
default['hadoop_kms']['log4j']['log4j.appender.kms.Append'] = 'true'
default['hadoop_kms']['log4j']['log4j.appender.kms.layout'] = 'org.apache.log4j.PatternLayout'
default['hadoop_kms']['log4j']['log4j.appender.kms.layout.ConversionPattern'] = '%d{ISO8601} %-5p %c{1} - %m%n'
default['hadoop_kms']['log4j']['log4j.appender.kms-audit'] = 'org.apache.log4j.DailyRollingFileAppender'
default['hadoop_kms']['log4j']['log4j.appender.kms-audit.DatePattern'] = '.yyyy-MM-dd'
default['hadoop_kms']['log4j']['log4j.appender.kms-audit.File'] = '${kms.log.dir}/kms-audit.log'
default['hadoop_kms']['log4j']['log4j.appender.kms-audit.Append'] = 'true'
default['hadoop_kms']['log4j']['log4j.appender.kms-audit.layout'] = 'org.apache.log4j.PatternLayout'
default['hadoop_kms']['log4j']['log4j.appender.kms-audit.layout.ConversionPattern'] = '%d{ISO8601} %m%n'
default['hadoop_kms']['log4j']['log4j.logger.kms-audit'] = 'INFO, kms-audit'
default['hadoop_kms']['log4j']['log4j.additivity.kms-audit'] = 'false'
default['hadoop_kms']['log4j']['log4j.rootLogger'] = 'ALL, kms'
default['hadoop_kms']['log4j']['log4j.logger.org.apache.hadoop.conf'] = 'ERROR'
default['hadoop_kms']['log4j']['log4j.logger.org.apache.hadoop'] = 'INFO'
default['hadoop_kms']['log4j']['log4j.logger.com.sun.jersey.server.wadl.generators.WadlGeneratorJAXBGrammarGenerator'] = 'OFF'

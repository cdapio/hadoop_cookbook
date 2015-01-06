# default log4j configuration parameters from the distribution

default['hadoop']['log4j']['hadoop.root.logger'] = 'INFO, console'
default['hadoop']['log4j']['hadoop.log.dir'] = '.'
default['hadoop']['log4j']['hadoop.log.file'] = 'hadoop.log'
default['hadoop']['log4j']['log4j.rootLogger'] = '${hadoop.root.logger}, EventCounter'
default['hadoop']['log4j']['log4j.threshold'] = 'ALL'
default['hadoop']['log4j']['log4j.appender.NullAppender'] = 'org.apache.log4j.varia.NullAppender'
default['hadoop']['log4j']['hadoop.log.maxfilesize'] = '256MB'
default['hadoop']['log4j']['hadoop.log.maxbackupindex'] = '20'

# RollingFileAppender
default['hadoop']['log4j']['log4j.appender.RFA'] = 'org.apache.log4j.RollingFileAppender'
default['hadoop']['log4j']['log4j.appender.RFA.File'] = '${hadoop.log.dir}/${hadoop.log.file}'
default['hadoop']['log4j']['log4j.appender.RFA.MaxFileSize'] = '${hadoop.log.maxfilesize}'
default['hadoop']['log4j']['log4j.appender.RFA.MaxBackupIndex'] = '${hadoop.log.maxbackupindex}'
default['hadoop']['log4j']['log4j.appender.RFA.layout'] = 'org.apache.log4j.PatternLayout'
default['hadoop']['log4j']['log4j.appender.RFA.layout.ConversionPattern'] = '%d{ISO8601} %p %c: %m%n'

# DailyRollingFileAppender
default['hadoop']['log4j']['log4j.appender.DRFA'] = 'org.apache.log4j.DailyRollingFileAppender'
default['hadoop']['log4j']['log4j.appender.DRFA.File'] = '${hadoop.log.dir}/${hadoop.log.file}'
default['hadoop']['log4j']['log4j.appender.DRFA.DatePattern'] = '.yyyy-MM-dd'
default['hadoop']['log4j']['log4j.appender.DRFA.layout'] = 'org.apache.log4j.PatternLayout'
default['hadoop']['log4j']['log4j.appender.DRFA.layout.ConversionPattern'] = '%d{ISO8601} %p %c: %m%n'

# ConsoleAppender
default['hadoop']['log4j']['log4j.appender.console'] = 'org.apache.log4j.ConsoleAppender'
default['hadoop']['log4j']['log4j.appender.console.target'] = 'System.err'
default['hadoop']['log4j']['log4j.appender.console.layout'] = 'org.apache.log4j.PatternLayout'
default['hadoop']['log4j']['log4j.appender.console.layout.ConversionPattern'] = '%d{yy/MM/dd HH:mm:ss} %p %c{2}: %m%n'

# TaskLogAppender
default['hadoop']['log4j']['hadoop.tasklog.taskid'] = 'null'
default['hadoop']['log4j']['hadoop.tasklog.iscleanup'] = 'false'
default['hadoop']['log4j']['hadoop.tasklog.noKeepSplits'] = '4'
default['hadoop']['log4j']['hadoop.tasklog.totalLogFileSize'] = '100'
default['hadoop']['log4j']['hadoop.tasklog.purgeLogSplits'] = 'true'
default['hadoop']['log4j']['hadoop.tasklog.logsRetainHours'] = '12'
default['hadoop']['log4j']['log4j.appender.TLA'] = 'org.apache.hadoop.mapred.TaskLogAppender'
default['hadoop']['log4j']['log4j.appender.TLA.taskId'] = '${hadoop.tasklog.taskid}'
default['hadoop']['log4j']['log4j.appender.TLA.isCleanup'] = '${hadoop.tasklog.iscleanup}'
default['hadoop']['log4j']['log4j.appender.TLA.totalLogFileSize'] = '${hadoop.tasklog.totalLogFileSize}'
default['hadoop']['log4j']['log4j.appender.TLA.layout'] = 'org.apache.log4j.PatternLayout'
default['hadoop']['log4j']['log4j.appender.TLA.layout.ConversionPattern'] = '%d{ISO8601} %p %c: %m%n'

# Uncomment the following to supress normal HDFS block state changes
# default['hadoop']['log4j']['log4j.logger.BlockStateChange'] = 'WARN'

# SecurityAppender
default['hadoop']['log4j']['hadoop.security.logger'] = 'INFO, NullAppender'
default['hadoop']['log4j']['hadoop.security.log.maxfilesize'] = '256MB'
default['hadoop']['log4j']['hadoop.security.log.maxbackupindex'] = '20'
default['hadoop']['log4j']['log4j.category.SecurityLogger'] = '${hadoop.security.logger}'
default['hadoop']['log4j']['hadoop.security.log.file'] = 'SecurityAuth-${user.name}.audit'
default['hadoop']['log4j']['log4j.appender.RFAS'] = 'org.apache.log4j.RollingFileAppender'
default['hadoop']['log4j']['log4j.appender.RFAS.File'] = '${hadoop.log.dir}/${hadoop.security.log.file}'
default['hadoop']['log4j']['log4j.appender.RFAS.layout'] = 'org.apache.log4j.PatternLayout'
default['hadoop']['log4j']['log4j.appender.RFAS.layout.ConversionPattern'] = '%d{ISO8601} %p %c: %m%n'
default['hadoop']['log4j']['log4j.appender.RFAS.MaxFileSize'] = '${hadoop.security.log.maxfilesize}'
default['hadoop']['log4j']['log4j.appender.RFAS.MaxBackupIndex'] = '${hadoop.security.log.maxbackupindex}'

# Daily Rolling Security Appender
default['hadoop']['log4j']['log4j.appender.DRFAS'] = 'org.apache.log4j.DailyRollingFileAppender'
default['hadoop']['log4j']['log4j.appender.DRFAS.File'] = '${hadoop.log.dir}/${hadoop.security.log.file}'
default['hadoop']['log4j']['log4j.appender.DRFAS.layout'] = 'org.apache.log4j.PatternLayout'
default['hadoop']['log4j']['log4j.appender.DRFAS.layout.ConversionPattern'] = '%d{ISO8601} %p %c: %m%n'
default['hadoop']['log4j']['log4j.appender.DRFAS.DatePattern'] = '.yyyy-MM-dd'

# Uncomment the following line to turn off configuration deprecation warnings.
# default['hadoop']['log4j']['log4j.logger.org.apache.hadoop.conf.Configuration.deprecation'] = 'WARN'

# HDFS Audit logging
default['hadoop']['log4j']['hdfs.audit.logger'] = 'INFO, NullAppender'
default['hadoop']['log4j']['hdfs.audit.log.maxfilesize'] = '256MB'
default['hadoop']['log4j']['hdfs.audit.log.maxbackupindex'] = '20'
default['hadoop']['log4j']['log4j.logger.org.apache.hadoop.hdfs.server.namenode.FSNamesystem.audit'] = '${hdfs.audit.logger}'
default['hadoop']['log4j']['log4j.additivity.org.apache.hadoop.hdfs.server.namenode.FSNamesystem.audit'] = 'false'
default['hadoop']['log4j']['log4j.appender.RFAAUDIT'] = 'org.apache.log4j.RollingFileAppender'
default['hadoop']['log4j']['log4j.appender.RFAAUDIT.File'] = '${hadoop.log.dir}/hdfs-audit.log'
default['hadoop']['log4j']['log4j.appender.RFAAUDIT.layout'] = 'org.apache.log4j.PatternLayout'
default['hadoop']['log4j']['log4j.appender.RFAAUDIT.layout.ConversionPattern'] = '%d{ISO8601} %p %c{2}: %m%n'
default['hadoop']['log4j']['log4j.appender.RFAAUDIT.MaxFileSize'] = '${hdfs.audit.log.maxfilesize}'
default['hadoop']['log4j']['log4j.appender.RFAAUDIT.MaxBackupIndex'] = '${hdfs.audit.log.maxbackupindex}'

# MapRed Audit logging
default['hadoop']['log4j']['mapred.audit.logger'] = 'INFO, NullAppender'
default['hadoop']['log4j']['mapred.audit.log.maxfilesize'] = '256MB'
default['hadoop']['log4j']['mapred.audit.log.maxbackupindex'] = '20'
default['hadoop']['log4j']['log4j.logger.org.apache.hadoop.mapred.AuditLogger'] = '${mapred.audit.logger}'
default['hadoop']['log4j']['log4j.additivity.org.apache.hadoop.mapred.AuditLogger'] = 'false'
default['hadoop']['log4j']['log4j.appender.MRAUDIT'] = 'org.apache.log4j.RollingFileAppender'
default['hadoop']['log4j']['log4j.appender.MRAUDIT.File'] = '${hadoop.log.dir}/mapred-audit.log'
default['hadoop']['log4j']['log4j.appender.MRAUDIT.layout'] = 'org.apache.log4j.PatternLayout'
default['hadoop']['log4j']['log4j.appender.MRAUDIT.layout.ConversionPattern'] = '%d{ISO8601} %p %c{2}: %m%n'
default['hadoop']['log4j']['log4j.appender.MRAUDIT.MaxFileSize'] = '${mapred.audit.log.maxfilesize}'
default['hadoop']['log4j']['log4j.appender.MRAUDIT.MaxBackupIndex'] = '${mapred.audit.log.maxbackupindex}'

# Jets3t library
default['hadoop']['log4j']['log4j.logger.org.jets3t.service.impl.rest.httpclient.RestS3Service'] = 'ERROR'

# Event Counter Appender
default['hadoop']['log4j']['log4j.appender.EventCounter'] = 'org.apache.hadoop.log.metrics.EventCounter'

# Job Summary Appender
default['hadoop']['log4j']['hadoop.mapreduce.jobsummary.logger'] = '${hadoop.root.logger}'
default['hadoop']['log4j']['hadoop.mapreduce.jobsummary.log.file'] = 'hadoop-mapreduce.jobsummary.log'
default['hadoop']['log4j']['hadoop.mapreduce.jobsummary.log.maxfilesize'] = '256MB'
default['hadoop']['log4j']['hadoop.mapreduce.jobsummary.log.maxbackupindex'] = '20'
default['hadoop']['log4j']['log4j.appender.JSA'] = 'org.apache.log4j.RollingFileAppender'
default['hadoop']['log4j']['log4j.appender.JSA.File'] = '${hadoop.log.dir}/${hadoop.mapreduce.jobsummary.log.file}'
default['hadoop']['log4j']['log4j.appender.JSA.MaxFileSize'] = '${hadoop.mapreduce.jobsummary.log.maxfilesize}'
default['hadoop']['log4j']['log4j.appender.JSA.MaxBackupIndex'] = '${hadoop.mapreduce.jobsummary.log.maxbackupindex}'
default['hadoop']['log4j']['log4j.appender.JSA.layout'] = 'org.apache.log4j.PatternLayout'
default['hadoop']['log4j']['log4j.appender.JSA.layout.ConversionPattern'] = '%d{yy/MM/dd HH:mm:ss} %p %c{2}: %m%n'
default['hadoop']['log4j']['log4j.logger.org.apache.hadoop.mapred.JobInProgress$JobSummary'] = '${hadoop.mapreduce.jobsummary.logger}'
default['hadoop']['log4j']['log4j.additivity.org.apache.hadoop.mapred.JobInProgress$JobSummary'] = 'false'

# YARN Application Summary Appender
default['hadoop']['log4j']['yarn.server.resourcemanager.appsummary.logger'] = '${hadoop.root.logger}'
default['hadoop']['log4j']['yarn.server.resourcemanager.appsummary.log.file'] = 'rm-appsummary.log'
default['hadoop']['log4j']['log4j.logger.org.apache.hadoop.yarn.server.resourcemanager.RMAppManager$ApplicationSummary'] =
  '${yarn.server.resourcemanager.appsummary.logger}'
default['hadoop']['log4j']['log4j.additivity.org.apache.hadoop.yarn.server.resourcemanager.RMAppManager$ApplicationSummary'] = 'false'
default['hadoop']['log4j']['log4j.appender.RMSUMMARY'] = 'org.apache.log4j.RollingFileAppender'
default['hadoop']['log4j']['log4j.appender.RMSUMMARY.File'] = '${hadoop.log.dir}/${yarn.server.resourcemanager.appsummary.log.file}'
default['hadoop']['log4j']['log4j.appender.RMSUMMARY.MaxFileSize'] = '256MB'
default['hadoop']['log4j']['log4j.appender.RMSUMMARY.MaxBackupIndex'] = '20'
default['hadoop']['log4j']['log4j.appender.RMSUMMARY.layout'] = 'org.apache.log4j.PatternLayout'
default['hadoop']['log4j']['log4j.appender.RMSUMMARY.layout.ConversionPattern'] = '%d{ISO8601} %p %c{2}: %m%n'

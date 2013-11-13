###
# cookbook settings
###
# Supported: cdh, hdp
default['hadoop']['distribution'] = 'hdp'
# Default: conf.chef
default['hadoop']['conf_dir'] = 'conf.chef'
default['hbase']['conf_dir'] = node['hadoop']['conf_dir']

###
# core-site.xml settings
###
default['hadoop']['core_site']['fs.defaultFS'] = 'hdfs://localhost'

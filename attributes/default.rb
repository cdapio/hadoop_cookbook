# Supported: hdp
default['hadoop']['distribution'] = 'hdp'
# Default: conf.chef
default['hadoop']['conf_dir'] = 'conf.chef'

###
# core-site.xml settings
###
default['hadoop']['core_site']['fs.defaultFS'] = 'hdfs://localhost'

default['tez']['conf_dir'] = node['hadoop']['conf_dir']

default['tez']['tez_site']['tez.lib.uris'] = '${fs.default.name}/apps/tez/,${fs.default.name}/apps/tez/lib/'
default['tez']['tez_env']['tez_conf_dir'] = "/etc/tez/#{node['tez']['conf_dir']}"
default['tez']['tez_env']['tez_jars'] = '/usr/lib/tez/*:/usr/lib/tez/lib/*'

default['hadoop']['hadoop_env']['hadoop_classpath'] = "/etc/tez/#{node['tez']['conf_dir']}:/usr/lib/tez/*:/usr/lib/tez/lib/*:$HADOOP_CLASSPATH"

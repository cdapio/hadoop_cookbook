default['tez']['tez_site']['tez.lib.uris'] = '${fs.default.name}/apps/tez/,${fs.default.name}/apps/tez/lib/'
default['tez']['tez_env']['tez_conf_dir'] = "/etc/tez/#{node['tez']['conf_dir']}"
default['tez']['tez_env']['tez_jars'] = '/usr/lib/tez/*:/usr/lib/tez/lib/*'

if node['hadoop'].key?('hadoop_env') && node['hadoop']['hadoop_env'].key?('hadoop_classpath')
  default['hadoop']['hadoop_env']['hadoop_classpath'] = "/etc/tez/#{node['tez']['conf_dir']}:/usr/lib/tez/*:/usr/lib/tez/lib/*:$HADOOP_CLASSPATH:#{default['hadoop']['hadoop_env']['hadoop_classpath']}"
else
  default['hadoop']['hadoop_env']['hadoop_classpath'] = "/etc/tez/#{node['tez']['conf_dir']}:/usr/lib/tez/*:/usr/lib/tez/lib/*:$HADOOP_CLASSPATH"
end

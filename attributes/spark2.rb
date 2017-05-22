# spark2-env.sh
default['spark2']['spark_env']['standalone_spark_master_host'] = node['fqdn']
default['spark2']['spark_env']['spark_master_ip']              = node['fqdn']
default['spark2']['spark_env']['spark_launch_with_scala']      = 0
default['spark2']['spark_env']['spark_library_path']           = '${SPARK_HOME}/lib'
default['spark2']['spark_env']['scala_library_path']           = '${SPARK_HOME}/lib'
default['spark2']['spark_env']['spark_master_webui_port']      = 18_080
default['spark2']['spark_env']['spark_worker_webui_port']      = 18_081
default['spark2']['spark_env']['spark_master_port']            = 7077
default['spark2']['spark_env']['spark_worker_port']            = 7078
default['spark2']['spark_env']['spark_pid_dir']                = '/var/run/spark2/'
default['spark2']['spark_env']['spark_history_server_log_dir'] = 'hdfs:///user/spark/applicationHistory'
default['spark2']['spark_env']['hadoop_conf_dir']              = '/etc/hadoop/conf'
default['spark2']['spark_env']['spark_dist_classpath']         = '$(hadoop classpath)'
# spark2-defaults.xml
default['spark2']['spark_defaults']['spark.eventLog.dir']               = 'hdfs:///user/spark/applicationHistory'
default['spark2']['spark_defaults']['spark.eventLog.enabled']           = true
default['spark2']['spark_defaults']['spark.yarn.historyServer.address'] = "#{node['fqdn']}:10020"

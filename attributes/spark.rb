# spark-env.sh
default['spark']['spark_env']['standalone_spark_master_host'] = node['fqdn']
default['spark']['spark_env']['spark_master_ip']              = node['fqdn']
default['spark']['spark_env']['spark_launch_with_scala']      = 0
default['spark']['spark_env']['spark_library_path']           = '${SPARK_HOME}/lib'
default['spark']['spark_env']['scala_library_path']           = '${SPARK_HOME}/lib'
default['spark']['spark_env']['spark_master_webui_port']      = 18_080
default['spark']['spark_env']['spark_worker_webui_port']      = 18_081
default['spark']['spark_env']['spark_master_port']            = 7077
default['spark']['spark_env']['spark_worker_port']            = 7078
default['spark']['spark_env']['spark_worker_dir']             = '/var/run/spark/work'
default['spark']['spark_env']['spark_log_dir']                = '/var/log/spark'
default['spark']['spark_env']['spark_pid_dir']                = '/var/run/spark/'
default['spark']['spark_env']['spark_history_server_log_dir'] = '/user/spark/applicationHistory'
default['spark']['spark_env']['hadoop_conf_dir']              = '/etc/hadoop/conf'
# spark-defaults.xml
default['spark']['spark_defaults']['spark.eventLog.dir']               = '/user/spark/applicationHistory'
default['spark']['spark_defaults']['spark.eventLog.enabled']           = true
default['spark']['spark_defaults']['spark.yarn.historyServer.address'] = "#{node['fqdn']}:10020"
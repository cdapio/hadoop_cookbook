
# spark release
default['spark']['release']['install']       = false
default['spark']['release']['install_path']  = '/opt'
default['spark']['release']['version'] = '1.1.0'
default['spark']['release']['package_type']  = 'hadoop2.3'
default['spark']['release']['checksum']      = '4d112223ab16a2b7fc4965e14bc9f9b1'

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
default['spark']['spark_env']['spark_pid_dir']                = '/var/run/spark/'
default['spark']['spark_env']['spark_history_server_log_dir'] = 'hdfs:///user/spark/applicationHistory'
default['spark']['spark_env']['hadoop_conf_dir']              = '/etc/hadoop/conf'
default['spark']['spark_env']['spark_dist_classpath']         = '$(hadoop classpath)'
# spark-defaults.xml
default['spark']['spark_defaults']['spark.eventLog.dir']               = 'hdfs:///user/spark/applicationHistory'
default['spark']['spark_defaults']['spark.eventLog.enabled']           = true
default['spark']['spark_defaults']['spark.yarn.historyServer.address'] = "#{node['fqdn']}:10020"

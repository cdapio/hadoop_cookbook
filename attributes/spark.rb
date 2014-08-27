###
# spark-env.sh
###
default['spark']['spark_env']['standalone_spark_master_host'] = node['fqdn']
default['spark']['spark_env']['spark_master_ip'] = node['spark']['spark_env']['standalone_spark_master_host']
# Run in JVM:
default['spark']['spark_env']['spark_launch_with_scala'] = '0'
default['spark']['spark_env']['spark_library_path'] = '${SPARK_HOME}/lib'
default['spark']['spark_env']['scala_library_path'] = '${SPARK_HOME}/lib'
default['spark']['spark_env']['spark_master_webui_port'] = '18080'
default['spark']['spark_env']['spark_master_port'] = '7077'
default['spark']['spark_env']['spark_worker_port'] = '7078'
default['spark']['spark_env']['spark_worker_webui_port'] = '18081'
default['spark']['spark_env']['spark_worker_dir'] = '/var/run/spark/work'
default['spark']['spark_env']['spark_log_dir'] = '/var/log/spark'

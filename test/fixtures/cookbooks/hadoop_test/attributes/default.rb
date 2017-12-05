# force HDFS format when notified
override['hadoop']['force_format'] = true
# disable setting limits
override['hadoop']['limits'] = []
# shrink heaps, use minimal settings
override['hadoop']['hadoop_env']['hadoop_heapsize'] = '256'
override['hadoop']['mapred_site']['mapreduce.map.java.opts'] = '-Xmx384m'
override['hadoop']['mapred_site']['mapreduce.reduce.java.opts'] = '-Xmx384m'
override['hadoop']['mapred_site']['mapreduce.job.maps'] = '3'
override['hadoop']['mapred_site']['mapreduce.job.reduces'] = '3'
override['hadoop']['mapred_site']['mapreduce.task.io.sort.factor'] = '10'
override['hadoop']['mapred_site']['mapreduce.task.io.sort.mb'] = '100'
override['hadoop']['yarn_env']['yarn_nodemanager_heapsize'] = '256'
override['hadoop']['yarn_site']['yarn.scheduler.minimum-allocation-mb'] = '256'

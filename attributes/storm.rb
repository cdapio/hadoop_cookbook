# storm release
default['storm']['release']['install']       = false
default['storm']['release']['install_path']  = '/opt'
default['storm']['release']['version']       = '0.9.5'
default['storm']['release']['checksum']      =
  case node['storm']['release']['version']
  when '0.9.5'
    '2e8337126de8d1e180abe77fb81af7c971f8c4b2dad94e446ac86c0f02ba3fb2'
  when '0.10.0-beta1'
    'e54b400b1e1a012149e74602e2441b355c433f27773e7191172342c8b595467d'
  end

# storm environment
# default['storm']['storm_env']['JAVA_HOME'] = 'home'
default['storm']['storm_env']['STORM_JAR_JVM_OPTS'] = '-Xmx64M -Xms32M'

# storm configuration
default['storm']['storm_conf']['nimbus.host'] = '127.0.0.1'
default['storm']['storm_conf']['storm.local.dir'] = '/var/lib/storm'
default['storm']['storm_conf']['storm.log.dir'] = '/var/log/storm'
default['storm']['storm_conf']['storm.zookeeper.servers'] = ['127.0.0.1']

# Define the amount of workers than can be run on this machine
# default['storm']['storm_conf']['supervisor.slots.ports'] = [
#   6700,
#   6701,
#   6702,
#   6703
# ]

## List of custom serializations
# default['storm']['storm_conf']['topology.kryo.register'] = [
#   'org.mycompany.MyType',
#   { 'org.mycompany.MyType2' => 'org.mycompany.MyType2Serializer' }
# ]

## List of custom kryo decorators
# default['storm']['storm_conf']['topology.kryo.decorators'] = ['org.mycompany.MyDecorator']

## Locations of the drpc servers
# default['storm']['storm_conf']['drpc.servers'] = [
#   'server1',
#   'server2'
# ]

## Metrics Consumers
# default['storm']['storm_conf']['topology.metrics.consumer.register'] = [
#   {'class' => 'backtype.storm.metric.LoggingMetricsConsumer',
#    'parallelism.hint' => 1},
#   {'class' => 'org.mycompany.MyMetricsConsumer',
#    'parallelism.hint' => 1,
#    'argument' => [{ 'endpoint' => 'metrics-collector.mycompany.org'}]}
# ]

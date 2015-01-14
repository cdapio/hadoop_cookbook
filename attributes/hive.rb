default['hive']['hive_site']['hive.metastore.uris'] = 'thrift://localhost:9083'
default['hive']['hive_site']['javax.jdo.option.ConnectionURL'] = 'jdbc:derby:;databaseName=/var/lib/hive/metastore/metastore_db;create=true'
default['hive']['hive_site']['javax.jdo.option.ConnectionDriverName'] = 'org.apache.derby.jdbc.EmbeddedDriver'

# These are the defaults for hbase-site.xml
default['hbase']['hbase_site']['hbase.rootdir'] = "#{node['hadoop']['core_site']['fs.defaultFS']}/hbase"
# These are the defaults for hbase-policy.xml
default['hbase']['hbase_policy']['security.client.protocol.acl'] = '*'
default['hbase']['hbase_policy']['security.admin.protocol.acl'] = '*'
default['hbase']['hbase_policy']['security.masterregion.protocol.acl'] = '*'
# limits.d settings
default['hbase']['limits']['nofile'] = '32768'
default['hbase']['limits']['memlock'] = 'unlimited'

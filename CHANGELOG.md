hadoop CHANGELOG
===============

v1.7.1 (Nov 5, 2014)
--------------------
- Hotfix symlink log dirs ( Issue: #119 )

v1.7.0 (Nov 5, 2014)
--------------------
- Use Java 7 by default ( Issue: #108 [COOK-5](https://issues.cask.co/browse/COOK-5) )
- Use HDP 2.1 by default ( Issue: #109 )
- Update tests ( Issues: #110 #111 #114 #115 #116 )
- Symlink default log dirs to new locations ( Issue: #113 )

v1.6.1 (Oct 16, 2014)
---------------------
- Update Bigtop to `0.8.0` release ( Issues: #106 #107 ) (COOK-1)

v1.6.0 (Oct 16, 2014)
---------------------
- Add Bigtop support ( Issue: #105 ) (COOK-1)

v1.5.0 (Sep 25, 2014)
---------------------
This release adds Flume support to the cookbook.

- Update test-kitchen to use more recipes ( Issue: #95 )
- Test improvements ( Issues: #98 #100 #101 )
- Flume support ( Issue: #99 )
- Simplify RHEL handling ( Issue: #102 )

v1.4.1 (Sep 18, 2014)
---------------------
- Add `zookeeper` group after package installs ( Issue: #96 )
- Code consistency updates ( Issue: #97 )

v1.4.0 (Sep 18, 2014)
---------------------
- Support Amazon Linux ( Issues: #84 #90 )
- Remove addition of `zookeeper` user/group ( Issue: #87 )
- Add support for HDP 2.1.5.0 ( Issue: #88 )
- Update HDP-UTILS to 1.1.0.19 ( Issue: #89 )
- Use `next` to break loops ( Issue: #91 )
- Hive HDFS directories use `hive` group ( Issue: #92 )
- Add Hive spec tests ( Issue: #93 )
- Update java cookbook dependency ( Issue: #94 )

There is no CHANGELOG for versions of this cookbook prior to 1.4.0 release.

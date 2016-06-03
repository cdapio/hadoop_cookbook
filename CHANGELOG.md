hadoop CHANGELOG
===============

v2.3.2 (May 6, 2016)
--------------------
- Improve test coverage ( Issue: #258 )
- HDP 2.2+ log directories are not modified on Ubuntu ( Issues: #259 [COOK-96](https://issues.cask.co/browse/COOK-96) )

v2.3.1 (Apr 19, 2016)
---------------------
- Allow overriding distribution_version at default ( Issues: #256 [COOK-93](https://issues.cask.co/browse/COOK-93) )
- Set SPARK_DIST_CLASSPATH and redirect STDERR to logs ( Issue: #257 )

v2.3.0 (Apr 12, 2016)
---------------------
- Change spark-defaults from XML to .conf property file ( Issue: #241 )
- Update default versions: HDP 2.3.4.7, CDH 5.6.0 ( Issue: #242 )
- Support HDP 2.3.4.7 and 2.4.0.0 ( Issue: #250 )
- Create hadoop_package helper for ODP-based distributions ( Issue: #251 )
- Revert change to zookeeper_server recipe from #251 ( Issue: #252 )
- Use oozie for service name, not pkg variable from #251 ( Issue: #253 )
- Remove unecessary inclusion of `yum::default` ( Issue: #254 )

v2.2.1 (Feb 24, 2016)
---------------------
- Support for HDP 2.3.4.0 per @kriszentner ( Issue: #243 )
- Style updates ( Issues: #244 #247 )
- Support for Bigtop 1.0.0 relocated repositories ( Issue: #245 )
- Fix to SPARK_HOME in the init scripts ( Issues: #248 )

v2.2.0 (Dec 16, 2015)
---------------------
- Add Code Climate badge ( Issue: #232 )
- Syntax fix in metadata.rb per @mrjefftang ( Issue: #234 )
- Fix up ImmutableMash/Array for older Chef per @mrjefftang ( Issue: #235 )
- Support Ubuntu 14 and Debian 7 for HDP 2.3.2.0+ per @kriszentner ( Issue: #236 )
- Support HDP 2.2.9.0 ( Issue: #237 )
- Revert #230 - Init scripts should use ampersand ( Issue: #238 )
- Fix Hive init scripts ( Issue: #239 )

v2.1.0 (Dec 7, 2015)
--------------------
- Add support for Apache Storm ( Issue: #223 )
- Support Bigtop 1.0.0 ( Issue: #224 )
- Update minimum `apt` cookbook dependency ( Issue: #227 )
- Support HDP 2.3.2.0 ( Issues: #228 [COOK-76](https://issues.cask.co/browse/COOK-76) )
- Update Gemfile dependencies ( Issue: #229 )
- Init scripts should use ampersand ( Issue: #230 )
- Update foodcritic constraint ( Issue: #231 )
- Reserve Hadoop ports from being used as local ports ( Issues: #233 [COOK-79](https://issues.cask.co/browse/COOK-79) )

v2.0.9 (Sep 16, 2015)
---------------------
- Support later HDP 2.1 and HDP 2.2 updates on Ubuntu ( Issue: #225 )

v2.0.8 (Sep 15, 2015)
---------------------
- Fix Hive init scripts, per @QuentinFra ( Issue: #220 )
- Correct JSVC_HOME for HDP 2.0 ( Issues: #221 [COOK-70](https://issues.cask.co/browse/COOK-70) )
- Support HDP 2.2.8.0 ( Issue: #222 )

v2.0.7 (Aug 21, 2015)
---------------------
- Fix Hive sql_connector jar on Ubuntu ( Issues: #216 [COOK-65](https://issues.cask.co/browse/COOK-65) )
- Style updates ( Issue: #217 )
- Set Yarn increment-allocation appropriately for Fair Scheduler ( Issues: #218 [COOK-67](https://issues.cask.co/browse/COOK-67) )

v2.0.6 (Jul 30, 2015)
---------------------
- Fix Spark CONF_DIR ( Issue: #215 )

v2.0.5 (Jul 30, 2015)
---------------------
- Support HDP 2.2.6.3 ( Issue: #212 )
- Keep HADOOP_CLASSPATH before Tez's CLASSPATH ( Issue: #213 )
- Support HDP 2.3.0.0 ( Issue: #214 )

v2.0.4 (Jul 23, 2015)
---------------------
- Fix ChefSpec ( Issue: #207 )
- Support HDP 2.1.15.0, 2.2.4.4, and 2.2.6.0 ( Issue: #208 )
- HiveServer2 process fix per @jsh2134 ( Issue: #210 )
- Fix HDP 2.2 yarn.application.classpath ( Issue: #211 )

v2.0.3 (Jun 25, 2015)
---------------------
- Config files should be root owned ( Issue: #204 )
- Fix disable THP Compaction ( Issues: #205 [COOK-57](https://issues.cask.co/browse/COOK-57) )
- Fix init for EXE_ARGS ending in ampersand ( Issues: #206 [COOK-59](https://issues.cask.co/browse/COOK-59) )

v2.0.2 (Jun 12, 2015)
---------------------
- Don't make /etc/default files executable ( Issue: #201 )
- Remove Vagrantfile ( Issue: #202 )
- Fix Ubuntu init ( Issue: #203 )

v2.0.1 (Jun 9, 2015)
--------------------
- Supply /etc/default/hbase for hbase binary ( Issue: #200 )

v2.0.0 (Jun 8, 2015)
--------------------
- Transparent Hugepages are not universally available, per @jdecello and @taverentech ( Issue: #156 )
- Support HDP 2.2.4.2 repo ( Issues: #160 #186 )
- Fix YARN/Hive/Oozie PATHs for HDP 2.2 ( Issue: #161 )
- Official CDH5 repo for Trusty ( Issue: #162 )
- Set user limits by attribute ( Issues: #163 #165 [COOK-35](https://issues.cask.co/browse/COOK-35) )
- Fix extjs link ( Issues: #164 [COOK-36](https://issues.cask.co/browse/COOK-36) )
- Use HDP mysql-connector-java ( Issues: #166 [COOK-34](https://issues.cask.co/browse/COOK-34) )
- Deprecate short versions ( Issue: #167 )
- Correct status for #156 ( Issue: #168 )
- Move SQL connectors to their own recipe ( Issue: #169 )
- Testing updates ( Issues: #170 #171 )
- Use Chef only_if guards over Ruby conditionals ( Issues: #172 #175 #176 #181 )
- Disable SELinux ( Issue: #173 )
- Install libhdfs ( Issue: #177 )
- Support HDP 2.1.10.0 and 2.2.1.0 ( Issue: #178 )
- Move compression libs to helper recipe ( Issues: #179 #187 [COOK-44](https://issues.cask.co/browse/COOK-44) )
- Ensure zookeeper user has shell access ( Issue: #180 )
- Use `variables` directly over local variable ( Issue: #181 )
- HDP 2.2 MR DistributedCache ( Issue: #182 [COOK-40](https://issues.cask.co/browse/COOK-40) )
- HDP 2.2 Tez DistributedCache ( Issue: #183 [COOK-49](https://issues.cask.co/browse/COOK-49) )
- Sort XML configuration keys, per @mbautin ( Issue: #184 )
- HDP 2.2 hadooplzo support ( Issue: #185 )
- Fix Java 7 type checking, per @TD-4242 ( Issue: #188 )
- Template-based init scripts ( Issues: #190 #194 #195 #196 [COOK-52](https://issues.cask.co/browse/COOK-52) [COOK-53](https://issues.cask.co/browse/COOK-53) )
- Set debian repository priority ( Issues: #191 #198 )
- Fix HDFS HA checkconfig, per @TD-4242 ( Issue: #192 )
- Initialize ZooKeeper `version-2` directories ( Issue: #193 )
- Support hadoop-metrics2.properties ( Issue: #197 )
- Remove guard on execute block with action :nothing ( Issue: #199 )

v1.13.1 (Apr 15, 2015)
-----------------------
- Fix YARN AM staging dir ( Issues: #157 [COOK-30](https://issues.cask.co/browse/COOK-30) )
- Support HDP 2.0.13.0 and bump HDP-UTILS to 1.1.0.20 ( Issue: #158 )
- Document issue tracker location ( Issues: #159 [COOK-32](https://issues.cask.co/browse/COOK-32) )

v1.13.0 (Mar 31, 2015)
----------------------
- Enable system tuning ( Issue: #148 )
- Test against more Ruby versions ( Issue: #153 )
- Fix guard on mapreduce.jobhistory.done-dir ( Issue: #154 )

v1.12.0 (Mar 20, 2015)
----------------------
- Support yarn.app.mapreduce.am.staging-dir ( Issue: #150 )
- Support mapreduce.jobhistory.done-dir and mapreduce.jobhistory.intermediate-done-dir ( Issue: #151 )
- Tests for #135 and #150 ( Issue: #152 )

v1.11.2 (Mar 9, 2015)
---------------------
- Prefix internal recipes with underscore ( Issue: #147 )
- Fix Java 7 check ( Issues: #149 [COOK-27](https://issues.cask.co/browse/COOK-27) )

v1.11.1 (Feb 27, 2015)
----------------------
- Packaging fix

v1.11.0 (Feb 27, 2015)
----------------------
- Stop packages from auto-starting on install ( Issues: #145 [COOK-26](https://issues.cask.co/browse/COOK-26) )
- Fail fast on invalid distribution ( Issues: #146 [COOK-25](https://issues.cask.co/browse/COOK-25) )

v1.10.1 (Feb 24, 2015)
----------------------
- HDP Repo fix ( Issues: #144 [COOK-24](https://issues.cask.co/browse/COOK-24) )

v1.10.0 (Feb 24, 2015)
----------------------
- Enforce Java 7 or higher on CDH 5.3 ( Issues: #140 [COOK-18](https://issues.cask.co/browse/COOK-18) )
- Default `hive.metastore.uris` ( Issues: #141 [COOK-19](https://issues.cask.co/browse/COOK-19) )
- HDP 2.2 support ( Issues: #142 [COOK-16](https://issues.cask.co/browse/COOK-16) )
- Recursive deletes on log dirs ( Issue: #143 [COOK-23](https://issues.cask.co/browse/COOK-23) )

v1.9.2 (Jan 8, 2015)
--------------------
- Defaults for log4j ( Issue: #139 )

v1.9.1 (Dec 9, 2014)
--------------------
- Spark tests for #129 ( Issue: #133 )
- Improve *_LOG_DIR symlink handling ( Issue: #134 )
- Fix PATH to `jsvc` in `/etc/default/hadoop` ( Issue: #135 )

v1.9.0 (Dec 8, 2014)
--------------------
- Tez support from @mandrews ( Issues: #127 #132 )

v1.8.1 (Dec 8, 2014)
--------------------
- Ubuntu Trusty support for CDH5 ( Issue: #128 )
- Spark MLib requires `libgfortran.so.3` ( Issue: #129 )
- Simplify `container-executor.cfg` ( Issue: #130 )
- Minor spark fixes from @pauloricardomg ( Issue: #131 )

v1.8.0 (Nov 24, 2014)
---------------------
- Opportunistic creation of `hive.exec.local.scratchdir` ( Issue: #117 )
- Only use `hadoop::repo` for Hive ( Issue: #120 )
- More Oozie tests ( Issue: #121 )
- Only test `hadoop::default` in Vagrant ( Issue: #122 )
- Avro libraries/tools support ( Issue: #123 [COOK-6](https://issues.cask.co/browse/COOK-6) )
- Parquet support ( Issue: #124 [COOK-7](https://issues.cask.co/browse/COOK-7) )
- Improve version matching for HDP 2.1 ( Issue: #125 )
- Initial Spark support ( Issue: #126 )

v1.7.1 (Nov 5, 2014)
--------------------
- Initial Oozie tests ( Issue: #118 )
- Hotfix symlink log dirs ( Issue: #119 )

v1.7.0 (Nov 5, 2014)
--------------------
- Use Java 7 by default ( Issue: #108 [COOK-5](https://issues.cask.co/browse/COOK-5) )
- Use HDP 2.1 by default ( Issue: #109 )
- Update tests ( Issues: #110 #111 #114 #115 #116 )
- Symlink default log dirs to new locations ( Issue: #113 )

v1.6.1 (Oct 16, 2014)
---------------------
- Update Bigtop to `0.8.0` release ( Issues: #106 #107 [COOK-1](https://issues.cask.co/browse/COOK-1) )

v1.6.0 (Oct 16, 2014)
---------------------
- Add Bigtop support ( Issue: #105 [COOK-1](https://issues.cask.co/browse/COOK-1) )

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

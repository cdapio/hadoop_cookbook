# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # We *need* vagrant-omnibus for these box images
  config.omnibus.chef_version = :latest

  # Enable berkshelf plugin
  config.berkshelf.enabled = true

  # config.vm.hostname = "hadoop-cookbook-berkshelf"

  # Run Multi-Machine environment to test both OSs
  # http://docs.vagrantup.com/v2/multi-machine/index.html
  config.vm.define :centos do |centos|
    centos.vm.box       = "opscode-centos-6.4"
    centos.vm.box_url   = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box"
    centos.vm.host_name = "hadoop-centos6-berkshelf"
    centos.vm.network :private_network, ip: "33.33.33.10"
  end

  config.vm.define :ubuntu do |ubuntu|
    ubuntu.vm.box       = "opscode-ubuntu-12.04"
    ubuntu.vm.box_url   = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box"
    ubuntu.vm.host_name = "hadoop-ubuntu12-berkshelf"
    ubuntu.vm.network :private_network, ip: "33.33.33.11"
  end

  # Every Vagrant virtual environment requires a box to build off of.
  # config.vm.box = "Berkshelf-CentOS-6.3-x86_64-minimal"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box"

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  # config.vm.network :private_network, ip: "33.33.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.

  # config.vm.network :public_network

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.
  config.vm.provider :virtualbox do |vb|
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  #config.ssh.max_tries = 40
  #config.ssh.timeout   = 120

  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []

  # Ubuntu needs this, but global provisioners run first
  config.vm.provision  :shell, :inline => 'test -x /usr/bin/apt-get && sudo apt-get update ; exit 0'

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :mysql => {
        :server_root_password => 'rootpass',
        :server_debian_password => 'debpass',
        :server_repl_password => 'replpass'
      },
      :java => {
        :install_flavor => 'oracle',
        :jdk_version => "6",
        :oracle => {
          :accept_oracle_download_terms => true
        }
      },
      :hadoop => {
        :container_executor => {
          'banned.users' => 'hdfs,yarn,mapred,bin'
        },
        :hdfs_site => {
          'dfs.datanode.max.xcievers' => 4096
        }
      },
      :hbase => {
        :hbase_site => {
          'hbase.rootdir' => 'hdfs://localhost:8020/hbase',
          'hbase.zookeeper.quorum' => 'localhost',
          'hbase.cluster.distributed' => true
        }
      },
      :hive => {
        :hive_site => {
          'hive.support.concurrency' => 'true',
          'hive.zookeeper.quorum' => 'localhost'
        }
      },
      :zookeeper => {
        :zoocfg => {
          :dataLogDir => '/tmp/zookeeper/logs'
        }
      }
    }

    chef.run_list = [
      "recipe[minitest-handler::default]",
      "recipe[java::default]",
      "recipe[hadoop::default]",
      "recipe[hadoop::hadoop_hdfs_namenode]",
      "recipe[hadoop::hadoop_hdfs_datanode]",
      "recipe[hadoop::hadoop_hdfs_secondarynamenode]",
      "recipe[hadoop::hadoop_yarn_resourcemanager]",
      "recipe[hadoop::hadoop_yarn_nodemanager]",
      "recipe[hadoop::zookeeper_server]",
      "recipe[hadoop::hbase_master]",
      "recipe[hadoop::hbase_regionserver]",
      "recipe[hadoop::hive_server2]",
      "recipe[hadoop::hive_metastore]",
      "recipe[hadoop::oozie]"
    ]
  end
end

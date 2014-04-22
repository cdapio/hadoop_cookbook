#
# Cookbook Name:: hadoop
# Library:: hdfs
#
# Copyright © 2014-2016 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Hadoop
  # Module for HDFS operations
  module Hdfs
    # Perform a test on an HDFS path
    #
    # @result Boolean
    def test(path, flag = 'e')
      Chef::Log.debug("Hadoop::Hdfs.test -#{flag} #{path}")
      cmd = "hadoop dfs -test -#{flag} #{path}".chomp
      mso = Mixlib::ShellOut.new(cmd)
      mso.run_command
      begin
        mso.error!
        true
      rescue
        false
      end
    end

    # See if a path exists in HDFS
    #
    # @result Boolean
    def exist?(path)
      test(path)
    end

    # Determine if an HDFS path is a directory
    #
    # @result Boolean
    def directory?(path)
      test(path, 'd')
    end

    # Determine if an HDFS path is a file
    #
    # @result Boolean
    def file?(path)
      test(path, 'f')
    end

    # Get string permissions from an HDFS path
    #
    # @result String
    def perms?(path)
      if directory?(path)
        cmd = "hadoop dfs -ls #{::File.dirname(path)} | grep #{::File.basename(path)} | awk '{print $1}'".chomp
      elsif file?(path)
        cmd = "hadoop dfs -ls #{path} | awk '{print $1}'".chomp
      else
        Chef::Application.fatal!("Cannot get permissions for #{path}")
      end
      mso = Mixlib::ShellOut.new(cmd)
      mso.run_command
      mso.stdout # | awk '{k=0; for(i=0;i<=8;i++) k+=((substr($1,i+2,1)~/[rwx]/)*2^(8-i));if (k) printf(" %0o ",k); print}'
    end

    # Get stat results from HDFS path
    #
    # @result String
    def stat?(path, format = nil)
      cmd = "hadoop dfs -stat #{format} #{path}".chomp
      mso = Mixlib::ShellOut.new(cmd)
      mso.run_command
      mso.stdout
    end

    # Get replication factor from an HDFS path
    #
    # @result String
    def replication?(path)
      stat?(path, '%r')
    end

    # Get owner from an HDFS path
    #
    # @result String
    def owner?(path)
      stat?(path, '%u')
    end

    # Get group from an HDFS path
    #
    # @result String
    def group?(path)
      stat?(path, '%g')
    end

    # Change group of an HDFS path
    #
    # @result Boolean
    def chgrp(path, group, recursive = false)
      change(path, 'grp', group, recursive)
    end

    # Change owner of an HDFS path
    #
    # @result Boolean
    def chown(path, owner, recursive = false)
      change(path, 'own', owner, recursive)
    end

    # Change mode of an HDFS path
    #
    # @result Boolean
    def chmod(path, mode, recursive = false)
      change(path, 'mod', mode, recursive)
    end

    # Create an HDFS directory
    #
    # @result Boolean
    def mkdir(path, recursive = false)
      Chef::Log.debug("Hadoop::Hdfs.mkdir #{path}")
      opts = '-p ' if recursive
      cmd = "hadoop dfs -mkdir #{opts}#{path}".chomp
      mso = Mixlib::ShellOut.new(cmd)
      mso.run_command
    end

    # Delete an HDFS object
    #
    # @result Boolean
    def delete(path, recursive = false, skiptrash = false)
      Chef::Log.debug("Hadoop::Hdfs.delete #{path}")
      opts = ''
      opts += '-R ' if recursive
      opts += '-skipTrash ' if skiptrash
      cmd = "hadoop dfs -rm #{opts}#{path}".chomp
      mso = Mixlib::ShellOut.new(cmd)
      mso.run_command
    end

    private

    # Change perms/group/owner of an HDFS path
    #
    # @result Boolean
    def change(path, element, arg, recursive = false)
      Chef::Log.debug("Hadoop::Hdfs.ch#{element} #{arg} #{path}, recursive=#{recursive}")
      opts = '-R ' if recursive
      cmd = "hadoop dfs -ch#{element} #{opts}#{arg} #{path}".chomp
      mso = Mixlib::ShellOut.new(cmd)
      mso.run_command
    end

    # Convert a single character to it's representation as a permission decimal value
    #
    # @result Integer
    def perms_char_to_int(char)
      case char
      when 'r'
        4
      when 'w'
        2
      when 'x', 't'
        1
      else
        0
      end
    end

    # Get decimal permissions from string permissions
    #
    # @result Integer
    def perms_to_decimal(perms)
      decimal = perms.split('')[9] == 't' ? 1000 : 0
      perms.split('')[1, 3].each do |p|
        decimal += (perms_char_to_int(p) * 100)
      end
      perms.split('')[4, 3].each do |p|
        decimal += (perms_char_to_int(p) * 10)
      end
      perms.split('')[7, 3].each do |p|
        decimal += perms_char_to_int(p)
      end
      decimal
    end
  end
end

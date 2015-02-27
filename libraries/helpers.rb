#
# Cookbook Name:: hadoop
# Library:: helpers
#
# Copyright © 2015 Cask Data, Inc.
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
  module Helpers
    def policy_rcd(cmd)
      case cmd
      when 'disable'
        Chef::Log.info('Disabling package auto-start')
        ::File.open('/usr/sbin/policy-rc.d', 'w', 0755) { |f| f.write('exit 101') }
      when 'enable'
        Chef::Log.info('Enabling package auto-start')
        ::File.delete('/usr/sbin/policy-rc.d') if ::File.exist?('/usr/sbin/policy-rc.d')
      else
        Chef::Application.fatal!('The policy_rc.d method only accepts "disable" or "enable" as arguments')
      end
    end
  end
end

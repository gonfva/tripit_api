#!/usr/bin/env ruby
#
# Copyright 2008-2012 Concur Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

require 'tripit/web_auth_credential'
require 'tripit/api'
require 'tripit/travel_obj'
require 'tripit/oauth_credential'
require 'rubygems'
require 'openssl'
require 'digest/md5'
require 'base64'
require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'
require 'rexml/document'
require 'json'
require 'date'



module TripIt


  # OAuth Core 1.0 Section 5.1 Parameter Encoding
  def self.urlencode(str)
      str = str.to_s
      str.gsub(/[^a-zA-Z0-9_\.\-\~]/n) do |s|
          sprintf('%%%02X', s.ord)
      end
  end

  def self.urlencode_args(args)
      args.collect do |k, v|
          urlencode(k) + '=' + urlencode(v)
      end.join('&')
  end

end


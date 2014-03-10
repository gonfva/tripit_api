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

NAME='tripit'

Gem::Specification.new do |s|
    s.name = NAME
    s.author = 'TripIt Inc.'
    s.email = 'support@tripit.com'
    s.homepage = 'http://www.tripit.com'
    s.summary = 'TripIt API Ruby Client Bindings'
    s.description = "A gem to help integrating with TripIt API"
    s.files = ['lib/tripit.rb','lib/tripit/web_auth_credential.rb']
    s.version = '1.0.1'
    s.add_dependency('json', '>= 0')
    s.license       = 'Apache-2.0'
end


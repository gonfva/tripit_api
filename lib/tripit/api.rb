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
module TripIt
  class API
    API_VERSION = 'v1'

    def initialize(credential, api_url='https://api.tripit.com', verify_ssl=false)
        @api_url = api_url
        @verify_ssl = verify_ssl
        @credential = credential
    end

    attr_reader :credential

    def get_request_token
        request_token = parse_query_string(do_request('/oauth/request_token'))

        @credential = OAuthCredential.new(@credential.consumer_key, \
            @credential.consumer_secret, \
            request_token['oauth_token'], \
            request_token['oauth_token_secret'])
    end

    def get_access_token
        access_token = parse_query_string(do_request('/oauth/access_token'))

        @credential = OAuthCredential.new(@credential.consumer_key, \
            @credential.consumer_secret, \
            access_token['oauth_token'], \
            access_token['oauth_token_secret'])
    end

    # Public method mappings
    class Verb
        def initialize
            yield self
        end

        def entity(*entities, &operation)
            entities.each do |entity|
                class << self
                    self
                end.send :define_method, entity do |*args|
                    operation.call(entity, *args)
                end
            end
        end
    end

    # Lists objects
    def list
        @list ||= Verb.new do |verb|
            verb.entity :trip, :object, :points_program do |entity, params|
                do_request('list', entity, params, nil)
            end
        end
    end

    # Gets an object by ID, or in the case of trips, with an optional filter
    def get
        @get ||= Verb.new do |verb|
            verb.entity :air, :lodging, :car, :rail, :transport, \
                :cruise, :restaurant, :activity, :note, :map, :directions, \
                :points_program \
            do |entity, id|
                do_request('get', entity, {:id=>id}, nil)
            end

            verb.entity :profile do |*args|
                entity = args[0]
                do_request('get', entity, nil, nil)
            end

            verb.entity :trip do |*args|
                entity, id, filter = args
                if filter.nil?
                    filter = {}
                end
                filter[:id] = id
                do_request('get', entity, filter, nil)
            end
        end
    end

    # Deletes an object by ID
    def delete
        @delete ||= Verb.new do |verb|
            verb.entity :trip, :air, :lodging, :car, :profile, :rail, \
                :transport, :cruise, :restaurant, :activity, :note, :map, \
                :directions \
            do |entity, id|
                do_request('delete', entity, {:id=>id}, nil)
            end
        end
    end

    # Takes either a TravelObj (as long as it is a valid top level Request
    # type), or a full XML Request
    def create(obj)
        do_request('create', nil, nil, {'xml' => obj_to_xml(obj)})
    end

    # Takes and ID and  either a TravelObj (as long as it is a valid top level
    # Request type), or a full XML Request.
    # Equivalent to a delete and a create, but they happen atomically.
    def replace
        @replace ||= Verb.new do |verb|
            verb.entity :trip, :air, :lodging, :car, :profile, :rail, \
                :transport, :cruise, :restaurant, :activity, :note, :map, \
                :directions \
            do |entity, id, obj|
                do_request('replace', entity, nil, {'id' => id, 'xml'=> obj_to_xml(obj)})
            end
        end
    end

    def crs_load_reservations(obj, company_key=nil)
        args = {'xml' => obj_to_xml(obj)}
        if not company_key.nil?
            args['company_key'] = company_key
        end
        do_request('crsLoadReservations', nil, nil, args)
    end

    def crs_delete_reservations(record_locator)
        do_request('crsDeleteReservations', nil, {'record_locator' => record_locator}, nil)
    end

private

    def obj_to_xml(obj)
        if obj.kind_of? TravelObj
            document = REXML::Document.new
            element = document.add_element('Request')
            obj.to_xml(element)
            document.to_s
        else
            obj.to_s
        end
    end

    def parse_query_string(string)
        params = {}
        string.split('&').each do |param|
            k, v = param.split('=', 2)
            params[k] = v
        end
        params
    end

    def parse_xml(xml)
        TravelObj.new(REXML::Document.new(xml))
    end

    # Makes a request POST/GET to the API and returns the response
    # from the server.
    # Throws an exception on error (non-200 response from the server).
    def do_request(verb, entity=nil, url_args=nil, post_args=nil)
        should_parse_xml = true
        url = URI(@api_url)
        if ['/oauth/request_token', '/oauth/access_token'].include?(verb)
            should_parse_xml = false
            url.path = verb
        else
            if not entity.nil?
                url.path = ['', API_VERSION, verb, entity].join('/')
            else
                url.path = ['', API_VERSION, verb].join('/')
            end
        end

        args = nil
        if not url_args.nil?
            args = url_args
            url.query = TripIt.urlencode_args(url_args)
        end

        request = nil
        if not post_args.nil?
            args = post_args
            request = Net::HTTP::Post.new(url.path)
            request.set_form_data(post_args)
        else
            request = Net::HTTP::Get.new(url.request_uri)
        end

        @credential.authorize(request, url, args)

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        if @verify_ssl
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end
        response = http.start do
            http.request(request)
        end

        if response.code == '200'
            if should_parse_xml
                parse_xml(response.body)
            else
                response.body
            end
        else
            response.error!
        end
    end
  end
end


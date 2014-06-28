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
  class OAuthCredential
    OAUTH_SIGNATURE_METHOD = 'HMAC-SHA1'
    OAUTH_VERSION = '1.0'

    def initialize(consumer_key, consumer_secret, token_or_requestor_id='', token_secret='')
        @consumer_key = consumer_key
        @consumer_secret = consumer_secret
        @token = @token_secret = @requestor_id = ''
        if token_or_requestor_id != '' and token_secret != ''
            @token = token_or_requestor_id
            @token_secret = token_secret
        elsif token_or_requestor_id != ''
            @requestor_id = token_or_requestor_id
        end
    end

    def authorize(request, url, args)
        request['Authorization'] = \
            generate_authorization_header(request.method, url, args)
    end

    def validate_signature(url)
        url = URI(url)
        parsed_params = CGI.parse(url.query)
        params = {}
        parsed_params.each_key do |key|
            params[key.intern] = parsed_params[key][0]
        end
        url.query = nil
        url = url.to_s

        signature = params[:oauth_signature]
        puts signature.inspect, generate_signature('GET', url, params).inspect

        return signature == generate_signature('GET', url, params)
    end

    def get_session_parameters(redirect_url, action)
        parameters = generate_oauth_parameters('GET', action, {'redirect_url' => redirect_url})
        parameters['redirect_url'] = redirect_url;
        parameters['action'] = action

        JSON.dump(parameters)
    end

    attr_reader :consumer_key, :consumer_secret, :token, :token_secret

private
    def generate_authorization_header(http_method, url, args)
        realm = URI(url.scheme + '://' + url.host + ':' + url.port.to_s).to_s
        base_url = URI(url.scheme + '://' + url.host + ':' + url.port.to_s + \
            url.path).to_s

        'OAuth realm="' + realm + '",' + \
        generate_oauth_parameters( \
        http_method, base_url, args).collect do |k, v|
            TripIt.urlencode(k) + '="' + TripIt.urlencode(v) + '"'
        end.join(',')
    end

    def generate_oauth_parameters(http_method, base_url, args)
        http_method.upcase!

        oauth_parameters = {
            :oauth_consumer_key => @consumer_key,
            :oauth_nonce => generate_nonce,
            :oauth_timestamp => Time.now.to_i,
            :oauth_signature_method => OAUTH_SIGNATURE_METHOD,
            :oauth_version => OAUTH_VERSION
        }

        if @token != ''
            oauth_parameters[:oauth_token] = @token
        end
        if @requestor_id != ''
            oauth_parameters[:xoauth_requestor_id] = @requestor_id
        end

        oauth_parameters_for_base_string = oauth_parameters.dup
        if not args.nil?
            oauth_parameters_for_base_string.merge!(args)
        end

        oauth_parameters[:oauth_signature] = generate_signature(http_method, base_url, oauth_parameters_for_base_string)

        oauth_parameters
    end

    def generate_signature(method, base_url, params)
        base_url = TripIt.urlencode(base_url)

        params.delete(:oauth_signature)

        # Get a list of the parameters sorted by key and
        # join them in key1=value1&key2=value2 form
        parameters = TripIt.urlencode(params.sort do |a, b|
            a[0].to_s <=> b[0].to_s
        end.collect do |k, v|
            TripIt.urlencode(k) + '=' + TripIt.urlencode(v)
        end.join('&'))

        signature_base_string = [method, base_url, parameters].join('&')

        key = @consumer_secret + '&' + @token_secret

        digest = OpenSSL::Digest.new('sha1')
        hashed = OpenSSL::HMAC.digest(digest, key, signature_base_string)
        Base64.encode64(hashed).chomp
    end

    # OAuth Core 1.0 Section 8 Nonce
    def generate_nonce
        chars = ('0'..'9').to_a
        size = 40
        random = (0...size).collect do
            chars[rand(chars.length)]
        end.join
        Digest::MD5.hexdigest(Time.now.to_f.to_s + random)
    end
  end
end


tripit
======

A gem to help integrating with TripIt API. Please see the LICENSE for copyright information.

Examples of use
---------------

### Installation


Add `tripit` to your Gemfile. (Warning. gem not yet published to rubygems)

``` ruby
gem 'tripit'
```

### Obtain a request token

``` ruby
oauth_credential = TripIt::OAuthCredential.new(
    consumer_key, consumer_secret)
t = TripIt::API.new(oauth_credential, api_url)

request_token = t.get_request_token

print "request token:  #{request_token.token}\n"
print "request secret: #{request_token.token_secret}\n"
```

### Obtain an authorized token

``` ruby
oauth_credential = TripIt::OAuthCredential.new(
    consumer_key, consumer_secret,
    request_token, request_token_secret)
t = TripIt::API.new(oauth_credential, api_url)

authorized_token = t.get_access_token

print "authorized token:  #{authorized_token.token}\n"
print "authorized secret: #{authorized_token.token_secret}\n"
```

### Actual requests

Get request (list of trips)

``` ruby
oauth_credential = TripIt::OAuthCredential.new(
    consumer_key, consumer_secret,
    authorized_token, authorized_token_secret)
t = TripIt::API.new(oauth_credential, api_url)
# print t.list.trip.to_xml.to_s

# Or with arguments
print t.list.trip({'include_objects' => 'true'}).to_xml.to_s
```

Post request (new trip)

``` ruby
trip_xml = "<Request><Trip>" \
           "<start_date>2009-12-09</start_date>" \
           "<end_date>2009-12-27</end_date>" \
           "<primary_location>New York, NY</primary_location>" \
           "</Trip></Request>"

oauth_credential = TripIt::OAuthCredential.new(
    consumer_key, consumer_secret,
    authorized_token, authorized_token_secret)

t = TripIt::API.new(oauth_credential, api_url)

puts t.create(trip_xml).to_xml.to_s
```



Additional documentation
------------------------

http://tripit.github.io/api/doc/v1/index.html


require 'tripit'

require 'test/unit'


class OAuthTest < Test::Unit::TestCase
  def test_initialize
    oauth=TripIt::OAuthCredential.new('user1','password1')
    assert_equal 'user1', oauth.consumer_key
  end
end


require 'tripit'

require 'test/unit'


class WebAuthTest < Test::Unit::TestCase
  def test_basic
    wauth=TripIt::WebAuthCredential.new('user1','password1')
    request = Request.new
    assert_equal ['user1','password1'], wauth.authorize(request,nil, nil)
  end

end

class Request
  def basic_auth(user, pass)
    [user,pass]
  end
end


require 'tripit'

require 'test/unit'


class ApiTest < Test::Unit::TestCase
  def test_initialize
    api=TripIt::API.new('credential')
    eval "def api.get_val; credential; end"
    assert_equal 'credential', api.get_val
  end
end


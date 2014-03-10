require 'tripit'

require 'test/unit'


class TravelObjTest < Test::Unit::TestCase
  def test_initialize

    obj='newTravel'
    eval "def obj.elements; []; end"
    xml = "<Request><Trip>" \
           "<start_date>2009-12-09</start_date>" \
           "<end_date>2009-12-27</end_date>" \
           "<primary_location>New York, NY</primary_location>" \
           "</Trip></Request>"
    travel=TripIt::TravelObj.new(REXML::Document.new(xml))
    assert_not_nil travel
    #assert_equal 'children', api.children
    assert_equal [], travel.elements
  end

end


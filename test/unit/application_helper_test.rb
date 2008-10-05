require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  tests ApplicationHelper

  test "pretty_date as html" do
    assert_equal "Thursday, 1<sup>st</sup> May", 
      pretty_date(Date.parse("2008-05-01"))

    assert_equal "Thursday, 1<sup>st</sup>", 
      pretty_date(Date.parse("2008-05-01"), false)
  end
end

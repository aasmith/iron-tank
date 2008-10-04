require 'test_helper'

class SplitTest < ActiveSupport::TestCase
  test "fixtures valid" do
    assert Split.all.all?(&:valid?)
  end

  test "since" do
    assert Split.since(3.days.ago).all?{|s|s.entry.posted > 3.days.ago.to_date}
  end
end

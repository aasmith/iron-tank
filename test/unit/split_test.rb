require 'test_helper'

class SplitTest < ActiveSupport::TestCase
  test "fixtures valid" do
    assert Split.all.all?(&:valid?)
  end
end

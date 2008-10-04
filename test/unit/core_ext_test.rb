require 'test_helper'

class CoreExtTest < ActiveSupport::TestCase
  test "Fixnum#oppose" do
    [-1,0,1].each do |i|
      assert_equal 0, i + i.oppose
    end
  end

  test "Money#format doesn't say 'free'" do
    [-1, 0, 1].each do |i|
      assert_match /\$-?[\.0]*#{i.abs}/, Money.new(i).format
    end
  end
end

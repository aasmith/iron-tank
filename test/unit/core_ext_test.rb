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

  test "Array#cap" do
    assert_equal ["1", "2", "3", 2], %w(1 2 3 4 5).cap(4)
    assert_equal %w(1 2), %w(1 2).cap(2)
    assert_equal %w(1 2), %w(1 2).cap(5)
    assert_equal %w(), %w().cap(5)
    assert_equal %w(), %w(1 2).cap(0)
  end
end

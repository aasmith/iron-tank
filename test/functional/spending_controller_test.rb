require 'test_helper'

class SpendingControllerTest < ActionController::TestCase
  test "get without days produces a default day range" do
    %w(day category).each do |action|
      assert_routing("/spending/#{action}",
        {:controller => 'spending', :action => action, :days => "30"})

      assert_recognizes(
        {:controller => 'spending', :action => action, :days => "30"},
        "/spending/#{action}")
    end
  end

  test "custom day is added to selection list of days" do
    %w(day category).each do |action|
      get action, :days => 40

      assert_equal 40, assigns("current_days")
      assert_equal [7, 30, 40, 60, 180], assigns("days")
    end
  end

  test "existing day is not added to selection list of days" do
    %w(day category).each do |action|
      get action, :days => 30

      assert_equal 30, assigns("current_days")
      assert_equal [7, 30, 60, 180], assigns("days")
    end
  end

end

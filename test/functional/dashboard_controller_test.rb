require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  test "basic index" do
    get :index, :days => 30
    assert_response :success
    assert_tag :tag => "link",
               :parent => { :tag => "head" },
               :attributes => { :href => /dashboard/ }
  end

  test "index without days produces a default day range" do
    assert_routing("dashboard",
      {:controller => 'dashboard', :action => 'index', :days => "30"})

    assert_recognizes(
      {:controller => 'dashboard', :action => 'index', :days => "30"},
      "dashboard/index")
  end

  test "custom day is added to selection list of days" do
    get :index, :days => 40

    assert_equal 40, assigns("current_days")
    assert_equal [7, 30, 40, 60, 180], assigns("days")
  end

  test "existing day is not added to selection list of days" do
    get :index, :days => 30

    assert_equal 30, assigns("current_days")
    assert_equal [7, 30, 60, 180], assigns("days")
  end

end

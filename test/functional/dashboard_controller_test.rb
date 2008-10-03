require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  test "basic index" do
    get :index
    assert_response :success
    assert_tag :tag => "link",
               :parent => { :tag => "head" },
               :attributes => { :href => /dashboard/ }
  end
end

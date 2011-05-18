require 'test_helper'

class WebextraControllerTest < ActionController::TestCase
  test "should get title:string" do
    get :title:string
    assert_response :success
  end

  test "should get summary:text" do
    get :summary:text
    assert_response :success
  end

  test "should get videourl:string" do
    get :videourl:string
    assert_response :success
  end

end

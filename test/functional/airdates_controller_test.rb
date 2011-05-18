require 'test_helper'

class AirdatesControllerTest < ActionController::TestCase
  setup do
    @airdate = airdates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:airdates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create airdate" do
    assert_difference('Airdate.count') do
      post :create, :airdate => @airdate.attributes
    end

    assert_redirected_to airdate_path(assigns(:airdate))
  end

  test "should show airdate" do
    get :show, :id => @airdate.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @airdate.to_param
    assert_response :success
  end

  test "should update airdate" do
    put :update, :id => @airdate.to_param, :airdate => @airdate.attributes
    assert_redirected_to airdate_path(assigns(:airdate))
  end

  test "should destroy airdate" do
    assert_difference('Airdate.count', -1) do
      delete :destroy, :id => @airdate.to_param
    end

    assert_redirected_to airdates_path
  end
end

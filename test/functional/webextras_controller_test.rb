require 'test_helper'

class WebextrasControllerTest < ActionController::TestCase
  setup do
    @webextra = webextras(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:webextras)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create webextra" do
    assert_difference('Webextra.count') do
      post :create, :webextra => @webextra.attributes
    end

    assert_redirected_to webextra_path(assigns(:webextra))
  end

  test "should show webextra" do
    get :show, :id => @webextra.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @webextra.to_param
    assert_response :success
  end

  test "should update webextra" do
    put :update, :id => @webextra.to_param, :webextra => @webextra.attributes
    assert_redirected_to webextra_path(assigns(:webextra))
  end

  test "should destroy webextra" do
    assert_difference('Webextra.count', -1) do
      delete :destroy, :id => @webextra.to_param
    end

    assert_redirected_to webextras_path
  end
end

require 'test_helper'

class ShootsControllerTest < ActionController::TestCase
  setup do
    @shoot = shoots(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shoots)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shoot" do
    assert_difference('Shoot.count') do
      post :create, :shoot => @shoot.attributes
    end

    assert_redirected_to shoot_path(assigns(:shoot))
  end

  test "should show shoot" do
    get :show, :id => @shoot.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @shoot.to_param
    assert_response :success
  end

  test "should update shoot" do
    put :update, :id => @shoot.to_param, :shoot => @shoot.attributes
    assert_redirected_to shoot_path(assigns(:shoot))
  end

  test "should destroy shoot" do
    assert_difference('Shoot.count', -1) do
      delete :destroy, :id => @shoot.to_param
    end

    assert_redirected_to shoots_path
  end
end

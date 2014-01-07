require 'test_helper'

class TestrunsControllerTest < ActionController::TestCase
  setup do
    @testrun = testruns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:testruns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create testrun" do
    assert_difference('Testrun.count') do
      post :create, testrun: { failed: @testrun.failed, passed: @testrun.passed, status: @testrun.status, total: @testrun.total }
    end

    assert_redirected_to testrun_path(assigns(:testrun))
  end

  test "should show testrun" do
    get :show, id: @testrun
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @testrun
    assert_response :success
  end

  test "should update testrun" do
    patch :update, id: @testrun, testrun: { failed: @testrun.failed, passed: @testrun.passed, status: @testrun.status, total: @testrun.total }
    assert_redirected_to testrun_path(assigns(:testrun))
  end

  test "should destroy testrun" do
    assert_difference('Testrun.count', -1) do
      delete :destroy, id: @testrun
    end

    assert_redirected_to testruns_path
  end
end

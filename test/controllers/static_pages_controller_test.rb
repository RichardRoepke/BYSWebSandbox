require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @title = 'BYS Web Sandbox'
  end

  test 'should render main properly when logged in and out.' do
    get root_path
    assert_response :success
    assert_select 'a[href=?]', new_user_session_path, count: 1
    assert_select 'a[href=?]', destroy_user_session_path, count: 0
    sign_in users(:one)
    get root_path
    assert_response :success
    assert_select 'a[href=?]', new_user_session_path, count: 0
    assert_select 'a[href=?]', destroy_user_session_path, count: 1
  end

  test 'should redirect when not logged in' do
    get utility_path
    assert_response :found
  end

  test 'should get main' do
    sign_in users(:one)
    get root_url
    assert_response :success
    assert_select 'title', "#{@title}: Main"
    assert_select 'a[href=?]', utility_path, count: 1
    assert_select 'a[href=?]', availability_path, count: 1
    assert_select 'a[href=?]', calculate_path, count: 1
    assert_select 'a[href=?]', reservationhold_path, count: 1
    assert_select 'a[href=?]', reservationconfirm_path, count: 1
    assert_select 'a[href=?]', siteusage_path, count: 1
    assert_select 'a[href=?]', reservationcreate_path, count: 1
    assert_select 'a[href=?]', sitecancel_path, count: 1
    assert_select 'a[href=?]', reservationreverse_path, count: 1
    assert_select 'a[href=?]', account_path, count: 1
  end

  test 'admin should only show for administrators' do
    sign_in users(:one)
    get root_url
    assert_select 'a[href=?]', admin_path, count: 0
    sign_out users(:one)

    sign_in users(:admin)
    get root_url
    assert_select 'a[href=?]', admin_path, count: 1
  end

  test 'can only access main when not logged in' do
    get root_url
    assert_response :success
    get service_path
    assert_response :found
    get misc_path
    assert_response :found

    sign_in users(:one)

    get root_url
    assert_response :success
    get service_path
    assert_response :success
    get misc_path
    assert_response :success
  end
end

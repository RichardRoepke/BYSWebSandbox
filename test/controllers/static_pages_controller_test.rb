require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @title = 'BYS Web Sandbox'
  end

  test 'should get main' do
    get root_url
    assert_response :success
    assert_select 'title', "#{@title}: Main"
    assert_select 'a[href=?]', utility_path, count: 2
    assert_select 'a[href=?]', availability_path, count: 2
    assert_select 'a[href=?]', calculate_path, count: 2
    assert_select 'a[href=?]', reservationhold_path, count: 2
    assert_select 'a[href=?]', reservationconfirm_path, count: 2
    assert_select 'a[href=?]', siteusage_path, count: 2
    assert_select 'a[href=?]', reservationcreate_path, count: 2
    assert_select 'a[href=?]', sitecancel_path, count: 2
    assert_select 'a[href=?]', reservationreverse_path, count: 2
  end
end

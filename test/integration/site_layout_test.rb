require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test 'layout links' do
    get root_path
    assert_select 'a[href=?]', new_user_session_path
    sign_in users(:one)
    get root_path
    assert_select 'a[href=?]', root_path
  end
end

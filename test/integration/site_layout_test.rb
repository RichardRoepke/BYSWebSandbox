require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test 'layout links' do
    sign_in_user
    get root_path
    assert_select 'a[href=?]', root_path
  end
end

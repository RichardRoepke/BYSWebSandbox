require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test 'layout links' do
    get root_path
    assert_select 'a[href=?]', root_path
    assert_select 'a[href=?]', utility_path
  end
end

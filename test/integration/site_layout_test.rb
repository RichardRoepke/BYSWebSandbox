require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links" do
    get root_path
    assert_select "a[href=?]", root_path
    assert_select "a[href=?]", unit_path, count: 2
    assert_select "a[href=?]", site_path, count: 2
    assert_select "a[href=?]", note_path, count: 2
  end
end
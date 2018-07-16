require 'test_helper'

class UtilityServicesControllerTest < ActionDispatch::IntegrationTest
  test "should get unit" do
    get utility_services_unit_url
    assert_response :success
  end

  test "should get site" do
    get utility_services_site_url
    assert_response :success
  end

  test "should get note" do
    get utility_services_note_url
    assert_response :success
  end

end

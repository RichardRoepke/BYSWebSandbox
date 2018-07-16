require 'test_helper'

class UtilityServicesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @title = "BYS Web Sandbox"
  end
  
  test "should get unit" do
    get unit_path
    assert_response :success
    assert_select "title", "#{@title}: Unit Type Information Service"
  end

  test "should get site" do
    get site_path
    assert_response :success
    assert_select "title", "#{@title}: Site Type Information Service"
  end

  test "should get note" do
    get note_path
    assert_response :success
    assert_select "title", "#{@title}: Notes and Terms Service"
  end

end

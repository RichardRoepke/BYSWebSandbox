require 'test_helper'

class UtilityServicesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @title = "BYS Web Sandbox"
  end
  
  test "should get generic" do
    get utility_path
    assert_response :success
    assert_select "title", "#{@title}: Utility Services"
  end

end

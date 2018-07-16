require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @title = "BYS Web Sandbox"
  end
   
  test "should get main" do
    get root_url
    assert_response :success
    assert_select "title", "#{@title}: Main"
  end

end

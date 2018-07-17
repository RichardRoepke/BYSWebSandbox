require 'test_helper'

class UtilityServicesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @requestIDs = ["UnitTypeInfoRequest", 
                   "SiteTypeInfoRequest", 
                   "NotesAndTermsRequest"]
  end
  
  test "should be setup properly" do
    get utility_path
    assert_response :success
    assert_select "title", "BYS Web Sandbox: Utility Services"
    
    assert_select "select[id=?]", "utility_form_requestID"
    
    @requestIDs.each do |id|
      assert_select "option[value=?]", id
    end
    
    assert_select "input[id=?]", "utility_form_parkID"
    assert_select "input[id=?]", "utility_form_securityKey"
    
    assert_select "input[value=?]", "Check XML"
    assert_select "input[value=?]", "Submit"
  end
  
  # utility_validator_test handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test "check for improper values" do
    get utility_path
    assert_response :success
    get utility_path, params: { info: "Check XML",
                                 utility_form: { requestID: "",
                                                 parkID: "",
                                                 securityKey: "" } }
    assert_select "div[class=?]", "errorExplanation", count: 4
  end
  
  test "generate and show proper xml on request" do
    get utility_path
    assert_response :success
    get utility_path, params: { info: "Check XML",
                                 utility_form: { requestID: @requestIDs[0],
                                                 parkID: "MC0000",
                                                 securityKey: "yes" } }
    assert_select "div[class=?]", "formatXML"
  end

end

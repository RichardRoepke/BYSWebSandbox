require 'test_helper'

class ServicesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @requestIDs = ["UnitTypeInfoRequest", 
                   "SiteTypeInfoRequest", 
                   "NotesAndTermsRequest",
                   "BYSPublicKeyRequest"]
                   
    @utilityform = { requestID: @requestIDs[0],
                     parkID: "MC1994",
                     securityKey: "yes" }
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
    get utility_path, params: { operation: "Check XML",
                                 utility_form: { requestID: "",
                                                 parkID: "",
                                                 securityKey: "" } }
    assert_select "div[class=?]", "errorExplanation", count: 4
  end
  
  test "generate and show proper xml on request" do
    get utility_path
    assert_response :success
    get utility_path, params: { operation: "Check XML",
                                 utility_form: @utilityform }
    assert_select "div[class=?]", "formatXML"
  end
  
  test "generate and show proper xml on submit" do
    get utility_path
    assert_response :success
    get utility_path, params: { operation: "Submit",
                                 utility_form: @utilityform }
    assert_select "div[class=?]", "formatXML"
  end
  
  test "error on requesting park not in database" do
    get utility_path
    assert_response :success
    
    @utilityform[:parkID] = "MC0000"
    get utility_path, params: { operation: "Submit",
                                 utility_form: @utilityform }
    assert_select "div[class=?]", "formatXML"
    assert_select "div[class=?]", "errorExplanation"
  end

end

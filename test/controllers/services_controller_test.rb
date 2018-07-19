require 'test_helper'

class ServicesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @requestIDs = ["UnitTypeInfoRequest", 
                   "SiteTypeInfoRequest", 
                   "NotesAndTermsRequest",
                   "BYSPublicKeyRequest"]
                   
    @utilityform = { request_ID: @requestIDs[0],
                     park_ID: "MC1994",
                     security_key: "yes" }
  end
  
  test "should be setup properly" do
    get utility_path
    assert_response :success
    assert_select "title", "BYS Web Sandbox: Utility Services"
    
    assert_select "select[id=?]", "utility_form_request_ID"
    
    @requestIDs.each do |id|
      assert_select "option[value=?]", id
    end
    
    assert_select "input[id=?]", "utility_form_park_ID"
    assert_select "input[id=?]", "utility_form_security_key"
    
    assert_select "input[value=?]", "Check XML"
    assert_select "input[value=?]", "Submit"
  end
  
  # utility_validator_test handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test "check for improper values" do
    get utility_path
    assert_response :success
    get utility_path, params: { user_action: "Check XML",
                                utility_form: { request_ID: "",
                                                park_ID: "",
                                                security_key: "" } }
    assert_select "div[class=?]", "errorExplanation", count: 4
  end
  
  test "generate and show proper xml on request" do
    get utility_path
    assert_response :success
    get utility_path, params: { user_action: "Check XML",
                                utility_form: @utilityform }
    assert_select "div[class=?]", "formatXML"
  end
  
  test "generate and show proper xml on submit" do
    get utility_path
    assert_response :success
    get utility_path, params: { user_action: "Submit",
                                utility_form: @utilityform }
    assert_select "div[class=?]", "formatXML"
  end
  
  test "error on requesting park not in database" do
    get utility_path
    assert_response :success
    
    @utilityform[:park_ID] = "MC0000"
    get utility_path, params: { user_action: "Submit",
                                utility_form: @utilityform }
    assert_select "div[class=?]", "formatXML"
    assert_select "div[class=?]", "errorExplanation"
  end

end

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
                     
    @availabilityform = { park_ID: "M00000",
                          security_key: "yes",
                          arrival_date: '2100-10-10',
                          num_nights: "5",
                          internal_UID: "5",
                          type_ID: "CABIN",
                          unit_length: "",
                          request_unav: "0"}
  end
  
  # ===============================================
  # Utility Services Tests Start
  # ===============================================
  test "utility: should be setup properly" do
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
  test "utility: check for improper values" do
    get utility_path
    assert_response :success
    get utility_path, params: { user_action: "Check XML",
                                utility_form: { request_ID: "",
                                                park_ID: "",
                                                security_key: "" } }
    assert_select "div[class=?]", "errorExplanation", count: 4
  end
  
  test "utility: generate and show proper xml on request" do
    get utility_path
    assert_response :success
    get utility_path, params: { user_action: "Check XML",
                                utility_form: @utilityform }
    assert_select "div[class=?]", "formatXML"
    assert_select "div[class=?]", "errorExplanation", count: 0
  end
  
  test "utility: generate and show proper xml on submit" do
    get utility_path
    assert_response :success
    get utility_path, params: { user_action: "Submit",
                                utility_form: @utilityform }
    assert_select "div[class=?]", "formatXML"
    assert_select "div[class=?]", "errorExplanation", count: 0
  end
  
  test "utility: error on requesting park not in database" do
    get utility_path
    assert_response :success
    
    @utilityform[:park_ID] = "MC0000"
    get utility_path, params: { user_action: "Submit",
                                utility_form: @utilityform }
    assert_select "div[class=?]", "formatXML"
    assert_select "div[class=?]", "errorExplanation"
  end
  # ===============================================
  # Utility Services Tests End
  # ===============================================
  
  # ===============================================
  # Site Availability Request Tests Start
  # ===============================================
  test "availability: should be setup properly" do
    get availability_path
    assert_response :success
    assert_select "title", "BYS Web Sandbox: Site Availabilty Request"
    
    assert_select "input[id=?]", "availability_form_park_ID"
    assert_select "input[id=?]", "availability_form_security_key"
    assert_select "input[id=?]", "availability_form_arrival_date"
    assert_select "input[id=?]", "availability_form_num_nights"
    assert_select "input[id=?]", "availability_form_internal_UID"
    assert_select "input[id=?]", "availability_form_type_ID"
    assert_select "input[id=?]", "availability_form_unit_length"
    assert_select "input[id=?]", "availability_form_request_unav"
    
    assert_select "input[type=?]", "checkbox", count: 1
    
    assert_select "input[value=?]", "Check XML"
    assert_select "input[value=?]", "Submit"
  end
  

  # availability_validator handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test "availability: check for improper values" do
    get availability_path
    assert_response :success
    get availability_path, params: { user_action: "Check XML",
                                     availability_form: { park_ID: "",
                                                          security_key: "",
                                                          arrival_date: '',
                                                          num_nights: "",
                                                          internal_UID: "",
                                                          type_ID: "",
                                                          unit_length: "",
                                                          request_unav: ""} }
    assert_select "div[class=?]", "errorExplanation", count: 8
  end

  test "availability: generate and show proper xml on request" do
    get availability_path
    assert_response :success
    get availability_path, params: { user_action: "Check XML",
                                     availability_form: @availabilityform }
    assert_select "div[class=?]", "formatXML"
    assert_select "div[class=?]", "errorExplanation", count: 0
  end
   
  test "availability: generate and show proper xml on submit" do
    get availability_path
    assert_response :success
    get availability_path, params: { user_action: "Submit",
                                     availability_form: @availabilityform }
    assert_select "div[class=?]", "formatXML"
  end
  
  test "availability: error on requesting park not in database" do
    get availability_path
    assert_response :success
    
    @availabilityform[:park_ID] = "MC0000"
    get availability_path, params: { user_action: "Submit",
                                     availability_form: @availabilityform }
    assert_select "div[class=?]", "formatXML"
    assert_select "div[class=?]", "errorExplanation"
  end
  # ===============================================
  # Site Availability Request Tests End
  # ===============================================

end

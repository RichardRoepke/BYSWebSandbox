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
                          
    @calculateform = { request_ID: "RateCalculationRequest",
                       park_ID: "MCU108",
                       security_key: "yes",
                       arrival_date: '2018-08-18',
                       num_nights: "8",
                       internal_UID: "59",
                       type_ID: "",
                       current_bill_num: 2,
                       "0".to_sym => { item: "Adults:", quantity: "1", type: "0" },
                       "1".to_sym => { item: "Children:", quantity: "2", type: "0" } }
                       
    @resholdform = { request_ID: "ReservationHoldRequest",
                     park_ID: "MCU108",
                     security_key: "yes",
                     reservation_ID: "UNIQUE",
                     rate_ID: "sure",
                     member_UUID: "7",
                     site_choice: { a: "C2", b: "", c: ""},
                     loyalty_code: "",
                     loyalty_text: "",
                     discount_code: "",
                     discount_text: "",
                     date: { arrival_date: '2018-08-18', num_nights: "3"},
                     site: { internal_UID: "59", type_ID: "" },
                     unit: { internal_UID: "47", type_ID: "", length: "" },
                     current_bill_num: 2,
                     "0".to_sym => { item: "Adults:", quantity: "1", type: "0" },
                     "1".to_sym => { item: "Children:", quantity: "2", type: "0" },
                     customer: { first_name: "Bobby",
                                 last_name: "Bob",
                                 email: "Bob@Bob.com",
                                 phone: "555-555-5555",
                                 phone_alt: "555-555-5555",
                                 address_one: "555 Bob street",
                                 address_two: "",
                                 city: "Bob Town",
                                 state_province: "Boblandia",
                                 postal_code: "L5L5L5",
                                 note: "No notes.",
                                 terms_accept: "1",
                                 cc_type: "VISA",
                                 cc_number: "4",
                                 cc_expiry: "99/99" } }
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
    assert_select "input[value=?]", "Force Submit"
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
    assert_select "input[value=?]", "Force Submit"
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
    assert_select "div[class=?]", "errorExplanation", count: 9
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
  
  # ===============================================
  # Rate Calcuation Request Tests Start
  # ===============================================
  test "calculation: should be setup properly" do
    get calculate_path
    assert_response :success
    assert_select "title", "BYS Web Sandbox: Rate Calculation Request"
    
    assert_select "input[id=?]", "calculate_form_park_ID"
    assert_select "input[id=?]", "calculate_form_security_key"
    assert_select "input[id=?]", "calculate_form_arrival_date"
    assert_select "input[id=?]", "calculate_form_num_nights"
    assert_select "input[id=?]", "calculate_form_internal_UID"
    assert_select "input[id=?]", "calculate_form_type_ID"
    assert_select "input[id=?]", "calculate_form_bill_num"
    assert_select "input[id=?]", "calculate_form_current_bill_num"
    
    assert_select "input[id=?]", "calculate_form_item0"
    assert_select "input[id=?]", "calculate_form_type0"
    assert_select "input[id=?]", "calculate_form_quantity0"
        
    assert_select "input[value=?]", "Check XML"
    assert_select "input[value=?]", "Submit"
    assert_select "input[value=?]", "Force Submit"
    assert_select "input[value=?]", "Update"
  end
  

  # calculation_validator handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test "calculation: check for improper values" do
    get calculate_path
    assert_response :success
    get calculate_path, params: { user_action: "Check XML",
                                     calculate_form: { park_ID: "",
                                                       security_key: "",
                                                       arrival_date: '',
                                                       num_nights: "",
                                                       internal_UID: "",
                                                       type_ID: "",
                                                       current_bill_num: 1,
                                                       item0: "", quantity0: "", type0: "0"} }
    assert_select "div[class=?]", "errorExplanation", count: 10
  end

  test "calculation: generate and show proper xml on request" do
    get calculate_path
    assert_response :success
    get calculate_path, params: { user_action: "Check XML",
                                  calculate_form: @calculateform }
    assert_select "div[class=?]", "formatXML"
    assert_select "div[class=?]", "errorExplanation", count: 0
  end
   
  test "calculation: generate and show proper xml on submit" do
    get calculate_path
    assert_response :success
    get calculate_path, params: { user_action: "Submit",
                                  calculate_form: @calculateform }
    # Figure this out when I get a proper example. 
    assert_select "div[class=?]", "formatXML"
  end
  
  test "calculation: error on requesting park not in database" do
    get calculate_path
    assert_response :success
    
    @calculateform[:park_ID] = "MC0000"
    get calculate_path, params: { user_action: "Submit",
                                  calculate_form: @calculateform }
    # Figure this out when I get a proper example.
    assert_select "div[class=?]", "formatXML"
    assert_select "div[class=?]", "errorExplanation"
  end
  
  test "calculation: extend and reduce billing numbers on update" do
    get calculate_path
    assert_response :success
    
    @calculateform[:bill_num] = "2"
    get calculate_path, params: { user_action: "Update",
                                  calculate_form: @calculateform }
    assert_select "input[id=calculate_form_item2]", false
    assert_select "input[id=calculate_form_quantity2]", false
    assert_select "input[id=calculate_form_type2]", false
    
    @calculateform[:bill_num] = "4"
    get calculate_path, params: { user_action: "Update",
                                  calculate_form: @calculateform }
    assert_select "input[id=?]", "calculate_form_quantity2"
    assert_select "input[id=?]", "calculate_form_item3"
    assert_select "input[id=?]", "calculate_form_quantity3"
    assert_select "input[id=?]", "calculate_form_type3" 
    
    @calculateform[:bill_num] = "1"
    get calculate_path, params: { user_action: "CheckXML",
                                  calculate_form: @calculateform }
    assert_select "input[id=?]", "calculate_form_quantity1"
    
    @calculateform[:bill_num] = "1"
    @calculateform[:current_bill_num] = "3"
    get calculate_path, params: { user_action: "CheckXML",
                                  calculate_form: @calculateform }
    assert_select "input[id=?]", "calculate_form_quantity1"
    assert_select "input[id=?]", "calculate_form_quantity2"
  end
  # ===============================================
  # Rate Calcuation Request Tests End
  # ===============================================
  
  # ===============================================
  # Reservation Hold Request Tests Start
  # ===============================================
  test "reservation hold should be setup properly" do
    get reservationhold_path
    assert_response :success
    assert_select "title", "BYS Web Sandbox: Reservation Hold Request"
  end
  

  # calculation_validator handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test "reservation hold: check for improper values" do
    get reservationhold_path
    assert_response :success
    get reservationhold_path, params: { user_action: "Check XML",
                                        res_hold_form: { request_ID: "",
                                                         park_ID: "",
                                                         security_key: "",
                                                         reservation_ID: "",
                                                         rate_ID: "",
                                                         member_UUID: "",
                                                         site_choice: { a: "", b: "", c: ""},
                                                         loyalty_code: "",
                                                         loyalty_text: "",
                                                         discount_code: "",
                                                         discount_text: "",
                                                         date: { arrival_date: '', num_nights: ""},
                                                         site: { internal_UID: "", type_ID: "" },
                                                         unit: { internal_UID: "", type_ID: "", length: "" },
                                                         current_bill_num: 2,
                                                         "0".to_sym => { item: "", quantity: "", type: "0" },
                                                         "1".to_sym => { item: "", quantity: "", type: "0" },
                                                         customer: { first_name: "",
                                                                     last_name: "",
                                                                     email: "",
                                                                     phone: "",
                                                                     phone_alt: "",
                                                                     address_one: "",
                                                                     address_two: "",
                                                                     city: "",
                                                                     state_province: "",
                                                                     postal_code: "",
                                                                     note: "",
                                                                     terms_accept: "",
                                                                     cc_type: "",
                                                                     cc_number: "",
                                                                     cc_expiry: "" } } }
    assert_select "div[class=?]", "errorExplanation", count: 26
  end

  test "reservation hold: generate and show proper xml on request" do
    get reservationhold_path
    assert_response :success
    get reservationhold_path, params: { user_action: "Check XML",
                                        res_hold_form: @resholdform }
    assert_select "div[class=?]", "formatXML"
    assert_select "div[class=?]", "errorExplanation", count: 0
  end
   
  test "reservation hold: generate and show proper xml on submit" do
    get reservationhold_path
    assert_response :success
    get reservationhold_path, params: { user_action: "Submit",
                                        res_hold_form: @resholdform }
    # Figure this out when I get a proper example. 
    assert_select "div[class=?]", "formatXML"
  end
  
  test "reservation hold: error on requesting park not in database" do
    get reservationhold_path
    assert_response :success
    
    @resholdform[:park_ID] = "MC0000"
    get reservationhold_path, params: { user_action: "Submit",
                                        res_hold_form: @resholdform }
    # Figure this out when I get a proper example.
    assert_select "div[class=?]", "formatXML"
    assert_select "div[class=?]", "errorExplanation"
  end
  
  test "reservation hold: extend and reduce billing numbers on update" do
    get reservationhold_path
    assert_response :success
    
    @resholdform[:bill_num] = "2"
    get reservationhold_path, params: { user_action: "Update",
                                        res_hold_form: @resholdform }
    assert_select "input[id=res_hold_form_item2]", false
    assert_select "input[id=res_hold_form_quantity2]", false
    assert_select "input[id=res_hold_form_type2]", false
    
    @resholdform[:bill_num] = "4"
    get reservationhold_path, params: { user_action: "Update",
                                        res_hold_form: @resholdform }
    assert_select "input[id=?]", "res_hold_form_quantity2"
    assert_select "input[id=?]", "res_hold_form_item3"
    assert_select "input[id=?]", "res_hold_form_quantity3"
    assert_select "input[id=?]", "res_hold_form_type3" 
    
    @resholdform[:bill_num] = "1"
    get reservationhold_path, params: { user_action: "CheckXML",
                                        res_hold_form: @resholdform }
    assert_select "input[id=?]", "res_hold_form_quantity1"
    
    @resholdform[:bill_num] = "1"
    @resholdform[:current_bill_num] = "3"
    get reservationhold_path, params: { user_action: "CheckXML",
                                        res_hold_form: @resholdform }
    assert_select "input[id=?]", "res_hold_form_quantity1"
    assert_select "input[id=?]", "res_hold_form_quantity2"
  end
  # ===============================================
  # Reservation Hold Request Tests End
  # ===============================================

end

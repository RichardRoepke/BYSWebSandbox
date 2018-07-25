require 'test_helper'

class ResCreateValidatorTest < ActiveSupport::TestCase
  def setup
    @init = { request_ID: "ReservationCreateRequest",
              park_ID: "MCU108",
              security_key: "yes",
              usage_token: "UNIQUE",
              billing: { current_bill_num: 2,
                         "0".to_sym => { item: "Adults:", quantity: "1", type: "0" },
                         "1".to_sym => { item: "Children:", quantity: "2", type: "0" } },
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
    @validator = ResCreateValidator.new(@init)
  end
  
  test "should be valid" do   
    assert @validator.valid?
  end
  
  test "path generation should be as expected" do
    assert_equal @validator.generate_path(), "https://54.197.134.112:3400/reservationcreate"
  end
  
  test "usage token should be present" do
    @init[:usage_token] = ""
    @validator = ResCreateValidator.new(@init)
    assert_not @validator.valid?
  end
  
  test "billing should be validated" do
    @init[:billing]["1".to_sym] = { item: "", quantity: "56", type: 1}
    @validator = ResCreateValidator.new(@init)
    assert_not @validator.valid?
  end
end
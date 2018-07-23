require 'test_helper'

class CustomerValidatorTest < ActiveSupport::TestCase
  def setup
    setup = { first_name: "Bobby",
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
              cc_expiry: "99/99" }
    @validator = CustomerValidator.new(setup)
  end
  
  test "should be valid" do
    assert @validator.valid?
  end
  
  test "first name should be present" do
    @validator.first_name = ""
    assert_not @validator.valid?
  end
  
  test "last name should be present" do
    @validator.last_name = ""
    assert_not @validator.valid?
  end
  
  test "email should be present" do
    @validator.email = ""
    assert_not @validator.valid?
  end
  
  test "address one should be present" do
    @validator.address_one = ""
    assert_not @validator.valid?
  end
  
  test "city should be present" do
    @validator.city = ""
    assert_not @validator.valid?
  end
  
  test "state or province should be present" do
    @validator.state_province = ""
    assert_not @validator.valid?
  end
  
  test "cc number should be present" do
    @validator.cc_number = ""
    assert_not @validator.valid?
  end
  
  test "phone number should be numbers and dashes" do
    @validator.phone = "A phone number"
    assert_not @validator.valid?
    @validator.phone = "555.555.5555"
    assert_not @validator.valid?
    @validator.phone = "************"
    assert_not @validator.valid?
  end
  
  test "phone number should be in the form NNN-NNN-NNNN" do
    @validator.phone = "5555555555"
    assert_not @validator.valid?
    @validator.phone = "---5---5----"
    assert_not @validator.valid?
  end
  
  test "alternate phone number should be numbers and dashes" do
    @validator.phone_alt = "A phone number"
    assert_not @validator.valid?
    @validator.phone_alt = "555.555.5555"
    assert_not @validator.valid?
    @validator.phone_alt = "************"
    assert_not @validator.valid?
  end
  
  test "alternate phone number should be in the form NNN-NNN-NNNN" do
    @validator.phone_alt = "5555555555"
    assert_not @validator.valid?
    @validator.phone_alt = "---5---5----"
    assert_not @validator.valid?
  end
  
  test "alternate phone number may not be present" do
    @validator.phone_alt = ""
    assert @validator.valid?
  end
  
  test "zip or postal codes must be alphanumeric." do
    @validator.postal_code = "%%%%%%%"
    assert_not @validator.valid?
    @validator.postal_code = "L5L 5L5"
    assert_not @validator.valid?
  end
  
  test "zip or postal codes should be accepted" do
    @validator.postal_code = "66666"
    assert @validator.valid?
    @validator.postal_code = "S3S3S3"
    assert @validator.valid?
  end
  
  test "terms accepted should be 0 or 1" do
    @validator.terms_accept = "1"
    assert @validator.valid?
    @validator.terms_accept = "0"
    assert @validator.valid?
    @validator.terms_accept = "5"
    assert_not @validator.valid?
  end
  
  test "cc type should be VISA or MC" do
    @validator.cc_type = "VISA"
    assert @validator.valid?
    @validator.cc_type = "MC"
    assert @validator.valid?
    @validator.cc_type = "5"
    assert_not @validator.valid?
  end
  
  test "cc expiry should be numbers and backslashes" do
    @validator.cc_expiry = "^^^"
    assert_not @validator.valid?
    @validator.cc_expiry = "aa/aa"
    assert_not @validator.valid?
    @validator.cc_expiry = "55/55"
    assert @validator.valid?
  end
  
  test "cc expiry should be in the form XX/YY" do
    @validator.cc_expiry = "//5//"
    assert_not @validator.valid?
    @validator.cc_expiry = "5566"
    assert_not @validator.valid?
  end
  
end
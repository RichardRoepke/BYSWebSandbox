require 'test_helper'
require 'date'

class AvailabilityValidatorTest < ActiveSupport::TestCase
  def setup
    setup = { request_ID: "SiteAvailabilityRequest",
              park_ID: "M00000",
              security_key: "yes",
              arrival_date: '2100-10-10',
              num_nights: "5",
              internal_UID: "5",
              type_ID: "CABIN",
              unit_length: "",
              request_unav: "0" }
    @validator = AvailabilityValidator.new(setup)
  end
  
  test "should be valid" do
    assert @validator.valid?
  end
  
  test "arrival date should be numbers and dashes" do
    @validator.arrival_date = "Bob@bob.com"
    assert_not @validator.valid?
  end
  
  test "arrival date should be YYYY-MM-DD" do
    @validator.arrival_date = "21001010"
    assert_not @validator.valid?
  end
  
  test "arrival date cannot be before today's date" do
    @validator.arrival_date = "1945-1-1"
    assert_not @validator.valid?
    @validator.arrival_date = Date.today.to_s
    assert @validator.valid?
  end
  
  test "number of nights must be a number" do
    @validator.num_nights = "One"
    assert_not @validator.valid?
  end
  
  test "number of nights must be a number greater than 0" do
    @validator.num_nights = "-1"
    assert_not @validator.valid?
    @validator.num_nights = "0"
    assert_not @validator.valid?
  end
  
  test "the internal UID must be a number" do
    @validator.internal_UID = "Two"
    assert_not @validator.valid?
  end
  
  test "the internal UID can be a number greater than 0" do
    @validator.internal_UID = "-1"
    assert_not @validator.valid?
    @validator.internal_UID = "0"
    assert_not @validator.valid?
  end
  
  test "the internal UID can be empty" do
    @validator.internal_UID = ""
    assert @validator.valid?
  end
  
  test "type ID must be alphanumeric, backslashes, dashes and underscores" do
    @validator.type_ID = "&&&&&"
    assert_not @validator.valid?
  end
  
  test "type ID can be empty" do
    @validator.type_ID = ""
    assert @validator.valid?
  end
  
  test "at least one of internal UID and type ID must be present" do
    @validator.internal_UID = ""
    @validator.type_ID = ""
    assert_not @validator.valid?
  end
  
  test "unit length must be a number" do
    @validator.unit_length = "Not a number"
    assert_not @validator.valid?
  end
  
  test "unit length must be between 1 and 100 if present" do
    @validator.unit_length = "0"
    assert_not @validator.valid?
    @validator.unit_length = "55"
    assert @validator.valid?
    @validator.unit_length = "101"
    assert_not @validator.valid?
  end
  
  test "request unavailable should be 0 or 1" do
    @validator.request_unav = "1"
    assert @validator.valid?
    @validator.request_unav = "0"
    assert @validator.valid?
    @validator.request_unav = "5"
    assert_not @validator.valid?
  end
  
  test "path generation should be as expected" do
    assert_equal @validator.generate_path(), "https://54.197.134.112:3400/siteavailability"
  end
  
  
 end
 
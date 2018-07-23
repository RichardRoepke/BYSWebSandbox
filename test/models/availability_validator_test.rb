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
 
require 'test_helper'
require 'date'

class DateValidatorTest < ActiveSupport::TestCase
  def setup
    @setup = { arrival_date: '2100-10-10',
               num_nights: "5" }
    @validator = DateValidator.new(@setup)
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
  
 end
 
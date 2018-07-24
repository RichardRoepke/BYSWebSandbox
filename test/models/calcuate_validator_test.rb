require 'test_helper'
require 'date'

class CalculateValidatorTest < ActiveSupport::TestCase
  def setup
    @init = { request_ID: "RateCalculationRequest",
              park_ID: "M00000",
              security_key: "yes",
              arrival_date: '2100-10-10',
              num_nights: "5",
              internal_UID: "5",
              type_ID: "CABIN",
              current_bill_num: 3,
              item0: "Adults", quantity0: "5", type0: "0",
              item1: "Children", quantity1: "2", type1: "0",
              item2: "Cable TV", quantity2: "1", type2: "1" }
               
    @validator = CalculateValidator.new(@init)
  end
  
  test "should be valid" do    
    assert @validator.valid?
  end
  
  test "path generation should be as expected" do
    assert_equal @validator.generate_path(), "https://54.197.134.112:3400/ratecalculation"
  end
  
  test "number of billing items should be variable" do
    @init[:current_bill_num] = 1
    @validator = CalculateValidator.new(@init)
    assert @validator.valid?
    
    @init[:current_bill_num] = 4
    @init[:item3] = "Pets"
    @init[:quantity3] = "0"
    @init[:type3] = "1"
    
    @validator = CalculateValidator.new(@init)
    assert @validator.valid?
  end
  
  
 end
 
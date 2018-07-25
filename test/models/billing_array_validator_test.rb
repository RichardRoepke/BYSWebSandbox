require 'test_helper'

class BillingArrayValidatorTest < ActiveSupport::TestCase
  def setup
    @init = { current_bill_num: 2,
              "0".to_sym => { item: "Adults:", quantity: "1", type: "0" },
              "1".to_sym => { item: "Children:", quantity: "2", type: "0" } }
    @validator = BillingArrayValidator.new(@init)
  end
  
  test "should be valid" do
    assert @validator.valid?
  end
  
  test "number of billing items should be variable" do
    @init[:current_bill_num] = 1
    @validator = BillingArrayValidator.new(@init)
    assert @validator.valid?
    
    @init[:current_bill_num] = 3
    @init["2".to_sym] = { item: "Pets", quantity: "0", type: "1" }
    @validator = BillingArrayValidator.new(@init)
    assert @validator.valid?
  end
  
  test "billing should be validated" do
    @init["1".to_sym][:item] = ""
    @init["1".to_sym][:quantity] = "56"
    @init["1".to_sym][:type] = "1"
    @validator = BillingArrayValidator.new(@init)
    assert_not @validator.valid?
  end
end
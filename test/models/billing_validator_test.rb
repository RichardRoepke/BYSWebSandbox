require 'test_helper'

class BillingValidatorTest < ActiveSupport::TestCase
  def setup
    setup = { item: "CHILDREN",
              type: "0",
              quantity: "0" }
    @validator = BillingValidator.new(setup)
  end
  
  test "should be valid" do
    assert @validator.valid?
  end
  
  test "billing item should be present" do
    @validator.item = ""
    assert_not @validator.valid?
  end
  
  test "billing type should be 0 or 1" do
    @validator.type = "1"
    assert @validator.valid?
    @validator.type = "0"
    assert @validator.valid?
    @validator.type = "5"
    assert_not @validator.valid?
  end
  
  test "billing quantity should be a number" do
    @validator.quantity = "NUMBER"
    assert_not @validator.valid?
    @validator.quantity = "1"
    assert @validator.valid?
    @validator.quantity = "10"
    assert @validator.valid?
  end
  
  test "billing type and quantity should match" do
    @validator.type = "0"
    @validator.quantity = "-1"
    assert_not @validator.valid?
    @validator.quantity = "0"
    assert @validator.valid?
    @validator.quantity = "1000"
    assert @validator.valid?
    @validator.quantity = ""
    assert_not @validator.valid?
    
    @validator.type = "1"
    @validator.quantity = "-10"
    assert_not @validator.valid?
    @validator.quantity = "0"
    assert @validator.valid?
    @validator.quantity = "1"
    assert @validator.valid?
    @validator.quantity = "1000"
    assert_not @validator.valid?
  end
  
  test "can initialize with empty" do
    @validator = BillingValidator.new({})
    assert @validator.item = ""
    assert @validator.type = ""
    assert @validator.quantity = ""
  end
end
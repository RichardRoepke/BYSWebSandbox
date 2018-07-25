require 'test_helper'

class SiteUsageValidatorTest < ActiveSupport::TestCase
  def setup
    @init = { request_ID: "SiteUsageHoldRequest",
              park_ID: "MCU108",
              security_key: "yes",
              usage_ID: "here",
              date: { arrival_date: '2018-08-18', num_nights: "8"},
              site: { internal_UID: "59", type_ID: ""},
              unit: { internal_UID: "47", type_ID: "", length: "5" },
              site_choice: { a: {internal_UID: "5", type_ID: "" },
                             b: {internal_UID: "", type_ID: "1" } } }
               
    @validator = SiteUsageValidator.new(@init)
  end
  
  test "should be valid" do    
    assert @validator.valid?
  end
  
  test "path generation should be as expected" do
    assert_equal @validator.generate_path(), "https://54.197.134.112:3400/siteusagehold"
  end
  
  test "site choice can be empty" do
    @init[:site_choice] = {}
    @validator = SiteUsageValidator.new(@init)
    assert @validator.valid?
    
    @init[:site_choice] = {a: {}, b: {}, c: {}}
    @validator = SiteUsageValidator.new(@init)    
    assert @validator.valid?
    
    @init[:site_choice] = { a: { internal_UID: "", type_ID: "" }, 
                            b: { internal_UID: "", type_ID: "" }, 
                            c: { internal_UID: "", type_ID: "" }}
    @validator = SiteUsageValidator.new(@init)    
    assert @validator.valid?
  end
  
  test "usage hold ID must be present" do
    @init[:usage_ID] = ""
    @validator = SiteUsageValidator.new(@init)
    assert_not @validator.valid?
  end
end
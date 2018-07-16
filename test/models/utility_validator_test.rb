require 'test_helper'

class UtilityValidatorTest < ActiveSupport::TestCase
  def setup
    @utility = UtilityValidator.new
    @utility.requestID = "UnitTypeInfoRequest"
    @utility.parkID = "M00000"
    @utility.securityKey = "yes"
  end
  
  test "should be valid" do
    assert @utility.valid?
  end
  
  test "only three accepted requestIDs" do
    @utility.requestID = "SiteTypeInfoRequest"
    assert @utility.valid?
    
    @utility.requestID = "NotesAndTermsRequest"
    assert @utility.valid?
    
    @utility.requestID = "UnitTypeInfoRequest"
    assert @utility.valid?
    
    @utility.requestID = "Wrong"
    assert_not @utility.valid?
  end
  
  test "park ID must be 6 characters long and start with M" do
    @utility.parkID = "M"
    assert_not @utility.valid?
    
    @utility.parkID = "M123456"
    assert_not @utility.valid?
    
    @utility.parkID = "000000"
    assert_not @utility.valid?
  end
  
  test "security key" do
    @utility.securityKey = nil
    assert_not @utility.valid?
  end
end
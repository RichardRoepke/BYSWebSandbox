require 'test_helper'

class UtilityValidatorTest < ActiveSupport::TestCase
  def setup
    setup = {request_ID: "UnitTypeInfoRequest",
             park_ID: "M00000",
             security_key: "yes"}
    @utility = UtilityValidator.new(setup)
  end
  
  test "should be valid" do
    assert @utility.valid?
  end
  
  test "accept SiteTypeInfoRequest" do
    @utility.request_ID = "SiteTypeInfoRequest"
    assert @utility.valid?
  end
  
  test "accept NotesAndTermsRequest" do  
    @utility.request_ID = "NotesAndTermsRequest"
    assert @utility.valid?
  end
  
  test "accept UnitTypeInfoRequest" do  
    @utility.request_ID = "UnitTypeInfoRequest"
    assert @utility.valid?
  end
  
  test "accept BYSPublicKeyRequest" do  
    @utility.request_ID = "BYSPublicKeyRequest"
    assert @utility.valid?
  end
  
  test "reject non-standard requestIDs" do   
    @utility.request_ID = "Wrong"
    assert_not @utility.valid?
  end
  
  test "park ID cannot be too short" do
    @utility.park_ID = "M"
    assert_not @utility.valid?
  end
  
  test "park ID cannot be too long" do  
    @utility.park_ID = "M123456"
    assert_not @utility.valid?
  end
  
  test "park ID must start with M" do  
    @utility.park_ID = "000000"
    assert_not @utility.valid?
  end
  
  test "park ID must use alphanumeric" do
    @utility.park_ID = "M#####"
    assert_not @utility.valid?
  end
  
  test "security key must exist" do
    @utility.security_key = nil
    assert_not @utility.valid?
  end
  
  #test "security ket must use alphanumeric" do
  #  @utility.securityKey = "%"
  #  assert_not @utility.valid?
  #end
end
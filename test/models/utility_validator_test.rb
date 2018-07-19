require 'test_helper'

class UtilityValidatorTest < ActiveSupport::TestCase
  def setup
    setup = {requestID: "UnitTypeInfoRequest",
             parkID: "M00000",
             securityKey: "yes"}
    @utility = UtilityValidator.new(setup)
  end
  
  test "should be valid" do
    assert @utility.valid?
  end
  
  test "accept SiteTypeInfoRequest" do
    @utility.requestID = "SiteTypeInfoRequest"
    assert @utility.valid?
  end
  
  test "accept NotesAndTermsRequest" do  
    @utility.requestID = "NotesAndTermsRequest"
    assert @utility.valid?
  end
  
  test "accept UnitTypeInfoRequest" do  
    @utility.requestID = "UnitTypeInfoRequest"
    assert @utility.valid?
  end
  
  test "accept BYSPublicKeyRequest" do  
    @utility.requestID = "BYSPublicKeyRequest"
    assert @utility.valid?
  end
  
  test "reject non-standard requestIDs" do   
    @utility.requestID = "Wrong"
    assert_not @utility.valid?
  end
  
  test "park ID cannot be too short" do
    @utility.parkID = "M"
    assert_not @utility.valid?
  end
  
  test "park ID cannot be too long" do  
    @utility.parkID = "M123456"
    assert_not @utility.valid?
  end
  
  test "park ID must start with M" do  
    @utility.parkID = "000000"
    assert_not @utility.valid?
  end
  
  test "park ID must use alphanumeric" do
    @utility.parkID = "M#####"
    assert_not @utility.valid?
  end
  
  test "security key must exist" do
    @utility.securityKey = nil
    assert_not @utility.valid?
  end
  
  #test "security ket must use alphanumeric" do
  #  @utility.securityKey = "%"
  #  assert_not @utility.valid?
  #end
end
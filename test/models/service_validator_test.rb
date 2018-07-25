require 'test_helper'

class ServiceValidatorTest < ActiveSupport::TestCase
  def setup
    setup = { request_ID: 'UnitTypeInfoRequest',
              park_ID: 'M00000',
              security_key: 'yes' }
    @service = ServiceValidator.new(setup)
  end

  test 'should be valid' do
    assert @service.valid?
  end

  test 'accept SiteTypeInfoRequest' do
    @service.request_ID = 'SiteTypeInfoRequest'
    assert @service.valid?
  end

  test 'accept NotesAndTermsRequest' do
    @service.request_ID = 'NotesAndTermsRequest'
    assert @service.valid?
  end

  test 'accept UnitTypeInfoRequest' do
    @service.request_ID = 'UnitTypeInfoRequest'
    assert @service.valid?
  end

  test 'accept BYSPublicKeyRequest' do
    @service.request_ID = 'BYSPublicKeyRequest'
    assert @service.valid?
  end

  test 'accept SiteAvailabilityRequest' do
    @service.request_ID = 'SiteAvailabilityRequest'
    assert @service.valid?
  end

  test 'reject non-standard requestIDs' do
    @service.request_ID = 'Wrong'
    assert_not @service.valid?
  end

  test 'park ID cannot be too short' do
    @service.park_ID = 'M'
    assert_not @service.valid?
  end

  test 'park ID cannot be too long' do
    @service.park_ID = 'M123456'
    assert_not @service.valid?
  end

  test 'park ID must start with M' do
    @service.park_ID = '000000'
    assert_not @service.valid?
  end

  test 'park ID must use alphanumeric' do
    @service.park_ID = 'M#####'
    assert_not @service.valid?
  end

  test 'security key must exist' do
    @service.security_key = nil
    assert_not @service.valid?
  end

  # test 'security key must use alphanumeric' do
  #  @service.securityKey = '%'
  #  assert_not @service.valid?
  # end
end

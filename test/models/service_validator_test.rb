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

  test 'version value if present' do
    @service.version_num = nil
    assert @service.valid?

    @service.version_num = 1
    assert @service.valid?

    @service.version_num = 0
    assert_not @service.valid?
  end

  test 'json_recursive_reformat has no effect on hashes without arrays' do
    hash = { test: { tester: { testone: '1',
                                testtwo: '2',
                                testthree: '3' },
                     testing: 'yes' } }
    assert @service.json_recursive_reformat(hash) == hash
  end

  test 'json_recursive_reformat reformats hashes with arrays' do
    hash = { test: { array: [0, 1, 3] },
             side: 'foobar' }
    expected = { test: [{array: 0}, {array: 1}, {array: 3}],
                  side: 'foobar' }
    result = @service.json_recursive_reformat(hash)
    assert_not result == hash
    assert result == expected
  end

  test 'reformat_array returns properly formatted array' do
    hash = { array: [0, 1, 3] }
    expected = [{array: 0}, {array: 1}, {array: 3}]

    result = @service.reformat_array(hash)
    assert result == expected
  end

  # test 'security key must use alphanumeric' do
  #  @service.securityKey = '%'
  #  assert_not @service.valid?
  # end
end

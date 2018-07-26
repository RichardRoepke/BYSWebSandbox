require 'test_helper'

class SiteCancelValidatorTest < ActiveSupport::TestCase
  def setup
    @init = { request_ID: 'SiteUsageCancelRequest',
              park_ID: 'M00000',
              security_key: 'yes',
              usage_token: 'token' }
    @validator = SiteCancelValidator.new(@init)
  end

  test 'should be valid' do
    assert @validator.valid?
  end

  test 'generate_path should generate proper ID addresses' do
    assert_equal @validator.generate_path, 'https://54.197.134.112:3400/siteusagecancel'
  end

  test 'usage token should be present' do
    @init[:usage_token] = ''
    @validator = SiteCancelValidator.new(@init)
    assert_not @validator.valid?
  end
end

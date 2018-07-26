require 'test_helper'

class SiteValidatorTest < ActiveSupport::TestCase
  def setup
    setup = { internal_UID: '5',
              type_ID: 'CABIN' }
    @validator = SiteValidator.new(setup)
  end

  test 'should be valid' do
    assert @validator.valid?
  end

  test 'the internal UID must be a number' do
    @validator.internal_UID = 'Two'
    assert_not @validator.valid?
  end

  test 'the internal UID can be a number greater than 0' do
    @validator.internal_UID = '-1'
    assert_not @validator.valid?

    @validator.internal_UID = '0'
    assert_not @validator.valid?

    # Previous implementation would reject numbers ending in 0.
    # Checking to make sure that doesn't happen again.
    @validator.internal_UID = '10'
    assert @validator.valid?
  end

  test 'the internal UID can be empty' do
    @validator.internal_UID = ''
    assert @validator.valid?
  end

  test 'type ID must be alphanumeric, backslashes, dashes and underscores' do
    @validator.type_ID = '&&&&&&'
    assert_not @validator.valid?
  end

  test 'type ID can be empty' do
    @validator.type_ID = ''
    assert @validator.valid?
  end

  test 'at least one of internal UID and type ID must be present' do
    @validator.type_ID = ''
    @validator.internal_UID = ''
    assert_not @validator.valid?
  end
end

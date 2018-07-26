require 'test_helper'

class UnitValidatorTest < ActiveSupport::TestCase
  def setup
    setup = { internal_UID: '5',
              type_ID: 'CABIN',
              length: '' }
    @validator = UnitValidator.new(setup)
  end

  test 'should be valid' do
    assert @validator.valid?
  end

  test 'unit length must be a number' do
    @validator.length = 'Not a number'
    assert_not @validator.valid?
  end

  test 'unit length must be between 1 and 100 if present' do
    @validator.length = '0'
    assert_not @validator.valid?
    @validator.length = '55'
    assert @validator.valid?
    @validator.length = '101'
    assert_not @validator.valid?

    # Previous implementation would reject numbers ending in 0.
    # Checking to make sure that doesn't happen again.
    @validator.length = '10'
    assert @validator.valid?
  end
end

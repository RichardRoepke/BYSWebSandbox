require 'test_helper'

class ResConfirmValidatorTest < ActiveSupport::TestCase
  def setup
    setup = { request_ID: 'ReservationConfirmRequest',
              park_ID: 'M00000',
              security_key: 'yes',
              reservation_ID: '2',
              hold_token: 'hold',
              action: 'CONFIRM' }
    @validator = ResConfirmValidator.new(setup)
  end

  test 'should be valid' do
    assert @validator.valid?
  end

  test 'path generation should be as expected' do
    assert_equal @validator.generate_path, 'https://54.197.134.112:3400/reservationconfirm'
  end

  test 'reservation ID should be present' do
    @validator.reservation_ID = ''
    assert_not @validator.valid?
  end

  test 'hold token should be present' do
    @validator.hold_token = ''
    assert_not @validator.valid?
  end

  test 'action must be Confirm or Cancel' do
    @validator.action = 'Neither'
    assert_not @validator.valid?
    @validator.action = '+1'
    assert_not @validator.valid?
    @validator.action = 'confirm'
    assert_not @validator.valid?
    @validator.action = 'cANCEL'
    assert_not @validator.valid?

    @validator.action = 'CONFIRM'
    assert @validator.valid?
    @validator.action = 'CANCEL'
    assert @validator.valid?
  end
end

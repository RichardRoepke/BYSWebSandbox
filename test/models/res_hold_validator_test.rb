require 'test_helper'

class ResHoldValidatorTest < ActiveSupport::TestCase
  def setup
    @init = { request_ID: 'ReservationHoldRequest',
              park_ID: 'MCU108',
              security_key: 'yes',
              reservation_ID: 'UNIQUE',
              rate_ID: 'sure',
              member_UUID: '7',
              site_choice: { a: 'C2', b: '', c: '' },
              loyalty_code: '',
              loyalty_text: '',
              discount_code: '',
              discount_text: '',
              date: { arrival_date: '2018-08-18', num_nights: '3' },
              site: { internal_UID: '59', type_ID: '' },
              unit: { internal_UID: '47', type_ID: '', length: '' },
              billing: { current_bill_num: 2,
                         '0'.to_sym => { item: 'Adults:',
                                         quantity: '1',
                                         type: '0' },
                         '1'.to_sym => { item: 'Children:',
                                         quantity: '2',
                                         type: '0' } },
              customer: { first_name: 'Bobby',
                          last_name: 'Bob',
                          email: 'Bob@Bob.com',
                          phone: '555-555-5555',
                          phone_alt: '555-555-5555',
                          address_one: '555 Bob street',
                          address_two: '',
                          city: 'Bob Town',
                          state_province: 'Boblandia',
                          postal_code: 'L5L5L5',
                          note: 'No notes.',
                          terms_accept: '1',
                          cc_type: 'VISA',
                          cc_number: '4',
                          cc_expiry: '99/99' } }
    @validator = ResHoldValidator.new(@init)
  end

  test 'should be valid' do
    assert @validator.valid?
  end

  test 'path generation should be as expected' do
    assert_equal @validator.generate_path, 'https://54.197.134.112:3400/reservationhold'
  end

  test 'loyalty valid when both text and code are both present/absent' do
    @validator.loyalty_code = ''
    @validator.loyalty_text = ''
    assert @validator.valid?

    @validator.loyalty_code = 'Foo'
    @validator.loyalty_text = ''
    assert_not @validator.valid?

    @validator.loyalty_code = ''
    @validator.loyalty_text = 'Bar'
    assert_not @validator.valid?

    @validator.loyalty_code = 'Foo'
    @validator.loyalty_text = 'Bar'
    assert @validator.valid?
  end

  test 'discount valid when both text and code are both present/absent' do
    @validator.discount_code = ''
    @validator.discount_text = ''
    assert @validator.valid?

    @validator.discount_code = 'Foo'
    @validator.discount_text = ''
    assert_not @validator.valid?

    @validator.discount_code = ''
    @validator.discount_text = 'Bar'
    assert_not @validator.valid?

    @validator.discount_code = 'Foo'
    @validator.discount_text = 'Bar'
    assert @validator.valid?
  end

  test 'rate calculation ID must be present' do
    @validator.rate_ID = ''
    assert_not @validator.valid?
  end

  test 'member UUID must be empty or a number' do
    @validator.member_UUID = ''
    assert @validator.valid?

    @validator.member_UUID = 'One'
    assert_not @validator.valid?
    @validator.member_UUID = '</>'
    assert_not @validator.valid?

    @validator.member_UUID = '123'
    assert @validator.valid?
  end

  test 'billing should be validated' do
    @init[:billing]['1'.to_sym] = { item: '', quantity: '56', type: '1' }
    @validator = ResHoldValidator.new(@init)
    assert_not @validator.valid?
  end
end

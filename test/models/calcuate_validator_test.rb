require 'test_helper'
require 'date'

class CalculateValidatorTest < ActiveSupport::TestCase
  def setup
    @init = { request_ID: 'RateCalculationRequest',
              park_ID: 'MCU108',
              security_key: 'yes',
              arrival_date: '2018-08-18',
              num_nights: '8',
              internal_UID: '59',
              type_ID: '',
              billing: { current_bill_num: 2,
                         '0'.to_sym => { item: 'Adults:',
                                         quantity: '1',
                                         type: '0' },
                         '1'.to_sym => { item: 'Children:',
                                         quantity: '2',
                                         type: '0' } } }

    @validator = CalculateValidator.new(@init)
  end

  test 'should be valid' do
    assert @validator.valid?
  end

  test 'path generation should be as expected' do
    assert_equal @validator.generate_path, 'https://54.197.134.112:3400/ratecalculation'
  end

  test 'number of billing items should be variable' do
    @init[:billing][:current_bill_num] = 1
    @validator = CalculateValidator.new(@init)
    assert @validator.valid?

    @init[:billing][:current_bill_num] = 3
    @init[:billing]['2'.to_sym] = { item: 'Pets', quantity: '0', type: '1' }
    @validator = CalculateValidator.new(@init)
    assert @validator.valid?
  end

  test 'billing should be validated' do
    @init[:billing]['1'.to_sym] = { item: '', quantity: '56', type: '1' }
    @validator = CalculateValidator.new(@init)
    assert_not @validator.valid?
  end
end

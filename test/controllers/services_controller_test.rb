require 'test_helper'

class ServicesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @requestIDs = %w[ UnitTypeInfoRequest
                      SiteTypeInfoRequest
                      NotesAndTermsRequest
                      BYSPublicKeyRequest ]

    @utilityform = { request_ID: @requestIDs[0],
                     park_ID: 'MC1994',
                     security_key: 'yes' }

    @availabilityform = { park_ID: 'M00000',
                          security_key: 'yes',
                          arrival_date: '2100-10-10',
                          num_nights: '5',
                          internal_UID: '5',
                          type_ID: 'CABIN',
                          unit_length: '',
                          request_unav: '0' }

    @calculateform = { request_ID: 'RateCalculationRequest',
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

    @resholdform = { request_ID: 'ReservationHoldRequest',
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

    @resconfirmform = { request_ID: 'ReservationConfirmRequest',
                        park_ID: 'M00000',
                        security_key: 'yes',
                        reservation_ID: '2',
                        hold_token: 'hold',
                        action: 'Confirm' }

    @siteusageform = { request_ID: 'SiteUsageHoldRequest',
                       park_ID: 'MCU108',
                       security_key: 'yes',
                       usage_ID: 'here',
                       date: { arrival_date: '2018-08-18', num_nights: '8' },
                       site: { internal_UID: '59', type_ID: '' },
                       unit: { internal_UID: '47', type_ID: '', length: '5' },
                       site_choice: { site1: { internal_UID: '5',
                                               type_ID: '' },
                                      site2: { internal_UID: '',
                                               type_ID: '1' },
                                      site3: { internal_UID: '',
                                               type_ID: '' } } }

    @rescreateform = { request_ID: 'ReservationCreateRequest',
                       park_ID: 'MCU108',
                       security_key: 'yes',
                       usage_token: 'UNIQUE',
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

    @sitecancelform = { request_ID: 'SiteUsageCancelRequest',
                        park_ID: 'M00000',
                        security_key: 'yes',
                        usage_token: 'Sure' }

    @resreverseform = { request_ID: 'SiteUsageCancelRequest',
                        park_ID: 'M00000',
                        security_key: 'yes',
                        res_token: 'Sure' }
  end

  # ===============================================
  # Utility Services Tests Start
  # ===============================================
  test 'utility: should be setup properly' do
    get utility_path
    assert_response :success
    assert_select 'title', 'BYS Web Sandbox: Utility Services'

    assert_select 'select[id=?]', 'utility_form_request_ID'

    @requestIDs.each do |id|
      assert_select 'option[value=?]', id
    end

    assert_select 'input[id=?]', 'utility_form_park_ID'
    assert_select 'input[id=?]', 'utility_form_security_key'

    assert_select 'input[value=?]', 'Check XML'
    assert_select 'input[value=?]', 'Submit'
    assert_select 'input[value=?]', 'Force Submit'
  end

  # utility_validator_test handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test 'utility: check for improper values' do
    get utility_path, params: { user_action: 'Check XML',
                                utility_form: { request_ID: '',
                                                park_ID: '',
                                                security_key: '' } }
    assert_select 'div[class=?]', 'errorExplanation', count: 4
  end

  test 'utility: generate and show proper xml on request' do
    get utility_path, params: { user_action: 'Check XML',
                                utility_form: @utilityform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation', count: 0
  end

  test 'utility: generate and show proper xml on submit' do
    get utility_path, params: { user_action: 'Submit',
                                utility_form: @utilityform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation', count: 0
  end

  test 'utility: error on requesting park not in database' do
    @utilityform[:park_ID] = 'MC0000'
    get utility_path, params: { user_action: 'Submit',
                                utility_form: @utilityform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation'
  end
  # ===============================================
  # Utility Services Tests End
  # ===============================================

  # ===============================================
  # Site Availability Request Tests Start
  # ===============================================
  test 'availability: should be setup properly' do
    get availability_path
    assert_response :success
    assert_select 'title', 'BYS Web Sandbox: Site Availabilty Request'

    assert_select 'input[id=?]', 'availability_form_park_ID'
    assert_select 'input[id=?]', 'availability_form_security_key'
    assert_select 'input[id=?]', 'availability_form_arrival_date'
    assert_select 'input[id=?]', 'availability_form_num_nights'
    assert_select 'input[id=?]', 'availability_form_internal_UID'
    assert_select 'input[id=?]', 'availability_form_type_ID'
    assert_select 'input[id=?]', 'availability_form_unit_length'
    assert_select 'input[id=?]', 'availability_form_request_unav'

    assert_select 'input[type=?]', 'checkbox', count: 1

    assert_select 'input[value=?]', 'Check XML'
    assert_select 'input[value=?]', 'Submit'
    assert_select 'input[value=?]', 'Force Submit'
  end

  # availability_validator handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test 'availability: check for improper values' do
    get availability_path, params: { user_action: 'Check XML',
                                     availability_form: { park_ID: '',
                                                          security_key: '',
                                                          arrival_date: '',
                                                          num_nights: '',
                                                          internal_UID: '',
                                                          type_ID: '',
                                                          unit_length: '',
                                                          request_unav: '' } }
    assert_select 'div[class=?]', 'errorExplanation', count: 9
  end

  test 'availability: generate and show proper xml on request' do
    get availability_path, params: { user_action: 'Check XML',
                                     availability_form: @availabilityform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation', count: 0
  end

  test 'availability: generate and show proper xml on submit' do
    get availability_path, params: { user_action: 'Submit',
                                     availability_form: @availabilityform }
    assert_select 'div[class=?]', 'formatXML'
  end

  test 'availability: error on requesting park not in database' do
    @availabilityform[:park_ID] = 'MC0000'
    get availability_path, params: { user_action: 'Submit',
                                     availability_form: @availabilityform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation'
  end
  # ===============================================
  # Site Availability Request Tests End
  # ===============================================

  # ===============================================
  # Rate Calcuation Request Tests Start
  # ===============================================
  test 'calculation: should be setup properly' do
    get calculate_path
    assert_response :success
    assert_select 'title', 'BYS Web Sandbox: Rate Calculation Request'

    assert_select 'input[id=?]', 'calculate_form_park_ID'
    assert_select 'input[id=?]', 'calculate_form_security_key'
    assert_select 'input[id=?]', 'calculate_form_arrival_date'
    assert_select 'input[id=?]', 'calculate_form_num_nights'
    assert_select 'input[id=?]', 'calculate_form_internal_UID'
    assert_select 'input[id=?]', 'calculate_form_type_ID'
    assert_select 'input[id=?]', 'calculate_form_bill_num'
    assert_select 'input[id=?]', 'calculate_form_current_bill_num'

    assert_select 'input[id=?]', 'calculate_form_item0'
    assert_select 'input[id=?]', 'calculate_form_type0'
    assert_select 'input[id=?]', 'calculate_form_quantity0'

    assert_select 'input[value=?]', 'Check XML'
    assert_select 'input[value=?]', 'Submit'
    assert_select 'input[value=?]', 'Force Submit'
    assert_select 'input[value=?]', 'Update'
  end

  # calculation_validator handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test 'calculation: check for improper values' do
    get calculate_path,
        params: { user_action: 'Check XML',
                  calculate_form: { park_ID: '',
                                    security_key: '',
                                    arrival_date: '',
                                    num_nights: '',
                                    internal_UID: '',
                                    type_ID: '',
                                    billing: { current_bill_num: 1,
                                               '0'.to_sym => { item: '',
                                                               quantity: '',
                                                               type: '0' } } } }
    assert_select 'div[class=?]', 'errorExplanation', count: 10
  end

  test 'calculation: generate and show proper xml on request' do
    get calculate_path, params: { user_action: 'Check XML',
                                  calculate_form: @calculateform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation', count: 0
  end

  test 'calculation: generate and show proper xml on submit' do
    get calculate_path, params: { user_action: 'Submit',
                                  calculate_form: @calculateform }
    assert_select 'div[class=?]', 'formatXML'
  end

  test 'calculation: error on requesting park not in database' do
    @calculateform[:park_ID] = 'MC0000'
    get calculate_path, params: { user_action: 'Submit',
                                  calculate_form: @calculateform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation'
  end

  test 'calculation: extend and reduce billing numbers on update' do
    @calculateform[:bill_num] = '2'
    get calculate_path, params: { user_action: 'Update',
                                  calculate_form: @calculateform }
    assert_select 'input[id=calculate_form_item2]', false
    assert_select 'input[id=calculate_form_quantity2]', false
    assert_select 'input[id=calculate_form_type2]', false

    @calculateform[:bill_num] = '4'
    get calculate_path, params: { user_action: 'Update',
                                  calculate_form: @calculateform }
    assert_select 'input[id=?]', 'calculate_form_quantity2'
    assert_select 'input[id=?]', 'calculate_form_item3'
    assert_select 'input[id=?]', 'calculate_form_quantity3'
    assert_select 'input[id=?]', 'calculate_form_type3'

    @calculateform[:bill_num] = '1'
    get calculate_path, params: { user_action: 'CheckXML',
                                  calculate_form: @calculateform }
    assert_select 'input[id=?]', 'calculate_form_quantity1'

    @calculateform[:bill_num] = '1'
    @calculateform[:billing][:current_bill_num] = '3'
    get calculate_path, params: { user_action: 'CheckXML',
                                  calculate_form: @calculateform }
    assert_select 'input[id=?]', 'calculate_form_quantity1'
    assert_select 'input[id=?]', 'calculate_form_quantity2'
  end
  # ===============================================
  # Rate Calcuation Request Tests End
  # ===============================================

  # ===============================================
  # Reservation Hold Request Tests Start
  # ===============================================
  test 'reservation hold should be setup properly' do
    get reservationhold_path
    assert_response :success
    assert_select 'title', 'BYS Web Sandbox: Reservation Hold Request'
  end

  # calculation_validator handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test 'reservation hold: check for improper values' do
    get reservationhold_path,
        params: { user_action: 'Check XML',
                  res_hold_form: { request_ID: '',
                                   park_ID: '',
                                   security_key: '',
                                   reservation_ID: '',
                                   rate_ID: '',
                                   member_UUID: '',
                                   site_choice: { a: '', b: '', c: '' },
                                   loyalty_code: '',
                                   loyalty_text: '',
                                   discount_code: '',
                                   discount_text: '',
                                   date: { arrival_date: '', num_nights: '' },
                                   site: { internal_UID: '', type_ID: '' },
                                   unit: { internal_UID: '',
                                           type_ID: '',
                                           length: '' },
                                   billing: { current_bill_num: 2,
                                              '0'.to_sym => { item: '',
                                                              quantity: '',
                                                              type: '0' },
                                              '1'.to_sym => { item: '',
                                                              quantity: '',
                                                              type: '0' } },
                                   customer: { first_name: '',
                                               last_name: '',
                                               email: '',
                                               phone: '',
                                               phone_alt: '',
                                               address_one: '',
                                               address_two: '',
                                               city: '',
                                               state_province: '',
                                               postal_code: '',
                                               note: '',
                                               terms_accept: '',
                                               cc_type: '',
                                               cc_number: '',
                                               cc_expiry: '' } } }
    assert_select 'div[class=?]', 'errorExplanation', count: 26
  end

  test 'reservation hold: generate and show proper xml on request' do
    get reservationhold_path, params: { user_action: 'Check XML',
                                        res_hold_form: @resholdform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation', count: 0
  end

  test 'reservation hold: generate and show proper xml on submit' do
    get reservationhold_path, params: { user_action: 'Submit',
                                        res_hold_form: @resholdform }
    assert_select 'div[class=?]', 'formatXML'
  end

  test 'reservation hold: error on requesting park not in database' do
    @resholdform[:park_ID] = 'MC0000'
    get reservationhold_path, params: { user_action: 'Submit',
                                        res_hold_form: @resholdform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation'
  end

  test 'reservation hold: extend and reduce billing numbers on update' do
    @resholdform[:bill_num] = '2'
    get reservationhold_path, params: { user_action: 'Update',
                                        res_hold_form: @resholdform }
    assert_select 'input[id=res_hold_form_item2]', false
    assert_select 'input[id=res_hold_form_quantity2]', false
    assert_select 'input[id=res_hold_form_type2]', false

    @resholdform[:bill_num] = '4'
    get reservationhold_path, params: { user_action: 'Update',
                                        res_hold_form: @resholdform }
    assert_select 'input[id=?]', 'res_hold_form_quantity2'
    assert_select 'input[id=?]', 'res_hold_form_item3'
    assert_select 'input[id=?]', 'res_hold_form_quantity3'
    assert_select 'input[id=?]', 'res_hold_form_type3'

    @resholdform[:bill_num] = '1'
    get reservationhold_path, params: { user_action: 'CheckXML',
                                        res_hold_form: @resholdform }
    assert_select 'input[id=?]', 'res_hold_form_quantity1'

    @resholdform[:bill_num] = '1'
    @resholdform[:billing][:current_bill_num] = '3'
    get reservationhold_path, params: { user_action: 'CheckXML',
                                        res_hold_form: @resholdform }
    assert_select 'input[id=?]', 'res_hold_form_quantity1'
    assert_select 'input[id=?]', 'res_hold_form_quantity2'
  end
  # ===============================================
  # Reservation Hold Request Tests End
  # ===============================================

  # ===============================================
  # Reservation Confirm Request Tests Start
  # ===============================================
  test 'reservation confirm: should be setup properly' do
    get reservationconfirm_path
    assert_response :success
    assert_select 'title', 'BYS Web Sandbox: Reservation Confirm Request'
  end

  # availability_validator handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test 'reservation confirm: check for improper values' do
    get reservationconfirm_path,
        params: { user_action: 'Check XML',
                  res_confirm_form: { request_ID: 'ReservationConfirmRequest',
                                      park_ID: '',
                                      security_key: '',
                                      reservation_ID: '',
                                      hold_token: '',
                                      action: '' } }
    assert_select 'div[class=?]', 'errorExplanation', count: 6
  end

  test 'reservation confirm: generate and show proper xml on request' do
    get reservationconfirm_path, params: { user_action: 'Check XML',
                                           res_confirm_form: @resconfirmform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation', count: 0
  end

  test 'reservation confirm: generate and show proper xml on submit' do
    # Once a way to test confirmations without setting stuff is found,
    # these tests will be revised.
    # get reservationconfirm_path
    # assert_response :success
    # get reservationconfirm_path, params: { user_action: 'Submit',
    #                                 res_confirm_form: @resholdform }
    # assert_select 'div[class=?]', 'formatXML'
  end

  test 'reservation confirm: error on requesting park not in database' do
    # Once a way to test confirmations without setting stuff is found,
    # these tests will be revised.

    # get reservationconfirm_path
    # assert_response :success

    # @resholdform[:park_ID] = 'MC0000'
    # get reservationconfirm_path, params: { user_action: 'Submit',
    #                                 res_confirm_form: @resholdform }
    # assert_select 'div[class=?]', 'formatXML'
    # assert_select 'div[class=?]', 'errorExplanation'
  end
  # ===============================================
  # Reservation Confirm Request Tests End
  # ===============================================

  # ===============================================
  # Site Usage Hold Request Tests Start
  # ===============================================
  test 'site usage: should be setup properly' do
    get siteusage_path
    assert_response :success
    assert_select 'title', 'BYS Web Sandbox: Site Usage Hold Request'
  end

  # availability_validator handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test 'site usage: check for improper values' do
    get siteusage_path,
        params: { user_action: 'Check XML',
                  site_usage_form: { request_ID: '',
                                     park_ID: '',
                                     security_key: '',
                                     usage_ID: '',
                                     date: { arrival_date: '', num_nights: '' },
                                     site: { internal_UID: '', type_ID: '' },
                                     unit: { internal_UID: '',
                                             type_ID: '',
                                             length: '' },
                                   site_choice: { site1: { internal_UID: 'test',
                                                           type_ID: '' },
                                                  site2: { internal_UID: 'test',
                                                           type_ID: '' },
                                                  site3: { internal_UID: 'test',
                                                           type_ID: '' } } } }
    assert_select 'div[class=?]', 'errorExplanation', count: 16
  end

  test 'site usage: generate and show proper xml on request' do
    get siteusage_path, params: { user_action: 'Check XML',
                                  site_usage_form: @siteusageform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation', count: 0
  end

  test 'site usage: generate and show proper xml on submit' do
    # Will be reactivated when I figure out a proper submission for site usage

    # get siteusage_path, params: { user_action: 'Submit',
    #                              site_usage_form: @resholdform }
    # assert_select 'div[class=?]', 'formatXML'
  end

  test 'site usage: error on requesting park not in database' do
    @siteusageform[:park_ID] = 'MC0000'
    get siteusage_path, params: { user_action: 'Submit',
                                  site_usage_form: @siteusageform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation'
  end
  # ===============================================
  # Site Usage Hold Request Tests End
  # ===============================================

  # ===============================================
  # Reservation Create Request Tests Start
  # ===============================================
  test 'reservation create should be setup properly' do
    get reservationcreate_path
    assert_response :success
    assert_select 'title', 'BYS Web Sandbox: Reservation Create Request'
  end

  # calculation_validator handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test 'reservation create: check for improper values' do
    get reservationcreate_path,
        params: { user_action: 'Check XML',
                  res_create_form: { request_ID: '',
                                     park_ID: '',
                                     security_key: '',
                                     usage_hold: '',
                                     billing: { current_bill_num: 2,
                                                '0'.to_sym => { item: '',
                                                                quantity: '',
                                                                type: '0' },
                                                '1'.to_sym => { item: '',
                                                                quantity: '',
                                                                type: '0' } },
                                     customer: { first_name: '',
                                                 last_name: '',
                                                 email: '',
                                                 phone: '',
                                                 phone_alt: '',
                                                 address_one: '',
                                                 address_two: '',
                                                 city: '',
                                                 state_province: '',
                                                 postal_code: '',
                                                 note: '',
                                                 terms_accept: '',
                                                 cc_type: '',
                                                 cc_number: '',
                                                 cc_expiry: '' } } }

    assert_select 'div[class=?]', 'errorExplanation', count: 19
  end

  test 'reservation create: generate and show proper xml on request' do
    get reservationcreate_path, params: { user_action: 'Check XML',
                                          res_create_form: @rescreateform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation', count: 0
  end

  test 'reservation create: generate and show proper xml on submit' do
    get reservationcreate_path, params: { user_action: 'Submit',
                                          res_create_form: @rescreateform }
    # Figure this out when I get a proper example.
    assert_select 'div[class=?]', 'formatXML'
  end

  test 'reservation create: error on requesting park not in database' do
    @rescreateform[:park_ID] = 'MC0000'
    get reservationcreate_path, params: { user_action: 'Submit',
                                          res_create_form: @rescreateform }
    # Figure this out when I get a proper example.
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation'
  end

  test 'reservation create: extend and reduce billing numbers on update' do
    @rescreateform[:bill_num] = '2'
    get reservationcreate_path, params: { user_action: 'Update',
                                          res_create_form: @rescreateform }
    assert_select 'input[id=res_create_form_item2]', false
    assert_select 'input[id=res_create_form_quantity2]', false
    assert_select 'input[id=res_create_form_type2]', false

    @rescreateform[:bill_num] = '4'
    get reservationcreate_path, params: { user_action: 'Update',
                                          res_create_form: @rescreateform }
    assert_select 'input[id=?]', 'res_create_form_quantity2'
    assert_select 'input[id=?]', 'res_create_form_item3'
    assert_select 'input[id=?]', 'res_create_form_quantity3'
    assert_select 'input[id=?]', 'res_create_form_type3'

    @rescreateform[:bill_num] = '1'
    get reservationcreate_path, params: { user_action: 'CheckXML',
                                          res_create_form: @rescreateform }
    assert_select 'input[id=?]', 'res_create_form_quantity1'

    @rescreateform[:bill_num] = '1'
    @rescreateform[:billing][:current_bill_num] = '3'
    get reservationcreate_path, params: { user_action: 'CheckXML',
                                          res_create_form: @rescreateform }
    assert_select 'input[id=?]', 'res_create_form_quantity1'
    assert_select 'input[id=?]', 'res_create_form_quantity2'
  end
  # ===============================================
  # Reservation Create Request Tests End
  # ===============================================

  # ===============================================
  # Site Usage Cancel Request Tests Start
  # ===============================================
  test 'site cancel should be setup properly' do
    get sitecancel_path
    assert_response :success
    assert_select 'title', 'BYS Web Sandbox: Site Usage Cancel Request'
  end

  # calculation_validator handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test 'site cancel: check for improper values' do
    get sitecancel_path, params: { user_action: 'Check XML',
                                   site_cancel_form: { request_ID: '',
                                                       park_ID: '',
                                                       security_key: '',
                                                       usage_token: '' } }
    assert_select 'div[class=?]', 'errorExplanation', count: 4
  end

  test 'site cancel: generate and show proper xml on request' do
    get sitecancel_path, params: { user_action: 'Check XML',
                                   site_cancel_form: @sitecancelform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation', count: 0
  end

  test 'site cancel: generate and show proper xml on submit' do
    get sitecancel_path, params: { user_action: 'Submit',
                                   site_cancel_form: @sitecancelform }
    assert_select 'div[class=?]', 'formatXML'
  end

  test 'site cancel: error on requesting park not in database' do
    @sitecancelform[:park_ID] = 'MC0000'
    get sitecancel_path, params: { user_action: 'Submit',
                                   site_cancel_form: @sitecancelform }
    # Figure this out when I get a proper example.
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation'
  end
  # ===============================================
  # Site Usage Cancel Request Tests End
  # ===============================================

  # ===============================================
  # Reservation Reverse Request Tests Start
  # ===============================================
  test 'reservation reverse: should be setup properly' do
    get reservationreverse_path
    assert_response :success
    assert_select 'title', 'BYS Web Sandbox: Reservation Reversal Request'
  end

  # calculation_validator handles the validation of values, so if this test
  # has a different error count that section should fail as well.
  test 'reservation reverse: check for improper values' do
    get reservationreverse_path, params: { user_action: 'Check XML',
                                           res_reverse_form: { request_ID: '',
                                                               park_ID: '',
                                                               security_key: '',
                                                               res_token: '' } }
    assert_select 'div[class=?]', 'errorExplanation', count: 4
  end

  test 'reservation reverse: generate and show proper xml on request' do
    get reservationreverse_path, params: { user_action: 'Check XML',
                                           res_reverse_form: @resreverseform }
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation', count: 0
  end

  test 'reservation reverse: generate and show proper xml on submit' do
    get reservationreverse_path, params: { user_action: 'Submit',
                                           res_reverse_form: @resreverseform }
    assert_select 'div[class=?]', 'formatXML'
  end

  test 'reservation reverse: error on requesting park not in database' do
    @resreverseform[:park_ID] = 'MC0000'
    get reservationreverse_path, params: { user_action: 'Submit',
                                           res_reverse_form: @resreverseform }
    # Figure this out when I get a proper example.
    assert_select 'div[class=?]', 'formatXML'
    assert_select 'div[class=?]', 'errorExplanation'
  end
  # ===============================================
  # Reservation Reverse Request Tests End
  # ===============================================
end

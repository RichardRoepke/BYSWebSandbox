require 'test_helper'

class ApiHelperTest < ActionDispatch::IntegrationTest
  include ApiHelper

  test 'check connection' do
    output = api_call('https://54.197.134.112:3400/helloworld', '', 'XML')
    assert_not output[:response_fault_title].present?
  end

end
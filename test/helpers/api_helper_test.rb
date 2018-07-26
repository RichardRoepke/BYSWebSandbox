require 'test_helper'

class ApiHelperTest < ActionDispatch::IntegrationTest
  include ApiHelper
  
  test 'check connection' do
    output = api_call('https://54.197.134.112:3400/helloworld', '')
    assert_not output[:xml_fault_title].present?
  end
  
end
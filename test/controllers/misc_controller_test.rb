require 'test_helper'

class MiscControllerTest < ActionDispatch::IntegrationTest
  def setup
    @requestIDs = %w{ unittypeinfo sitetypeinfo notesandterms byspublickey
                      siteavailability ratecalculation reservationhold
                      reservationconfirm siteusagehold reservationcreate
                      siteusagecancel reservationreverse }
  end
  
  test 'xml parse: should be setup properly' do
    get xmlparse_path
    assert_response :success
    assert_select 'title', 'BYS Web Sandbox: XML Parser'

    assert_select 'select[id=?]', 'input_form_request_ID'

    @requestIDs.each do |id|
      assert_select 'option[value=?]', id
    end
    
    assert_select 'input[value=?]', 'Submit'
  end
end

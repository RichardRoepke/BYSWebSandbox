require 'test_helper'

class MiscControllerTest < ActionDispatch::IntegrationTest
  def setup
    sign_in users(:one)

    @requestIDs = %w{ unittypeinfo sitetypeinfo notesandterms byspublickey
                      siteavailability ratecalculation reservationhold
                      reservationconfirm siteusagehold reservationcreate
                      siteusagecancel reservationreverse }
  end

  test 'can only access pages when logged in' do
    get textparse_path
    assert_response :success
    get account_path
    assert_response :success

    sign_out users(:one)

    get textparse_path
    assert_response :found
    get account_path
    assert_response :found
  end

  test 'account: can change security key without password' do
    assert_not users(:one).security == 'BETTER'
    get account_path, params: { input_form: { security: 'BETTER' }, commit: 'Update Account' }
    assert_response :found
    assert flash[:success].present?
    assert users(:one).security == 'BETTER'
  end

  test 'account: can change password' do
    sign_out users(:one)

    # The obvious solution to being unable to setup an ecrypted passwords in the fixtures.
    user = User.new({email: 'foobar@foo.com', password: 'foobar', password_confirmation: 'foobar'})
    user.save
    sign_in user

    get account_path, params: { input_form: { old_password: 'foobar', password: 'barfoo', password_confirmation: 'barfoo' }, commit: 'Update Account' }
    assert_response :found
    assert flash[:success].present?
  end

  test 'account: need to enter current password to change the password' do
    sign_out users(:one)

    # The obvious solution to being unable to setup an ecrypted passwords in the fixtures.
    user = User.new({email: 'foobar@foo.com', password: 'foobar', password_confirmation: 'foobar'})
    user.save
    sign_in user

    get account_path, params: { input_form: { password: 'barfoo', password_confirmation: 'barfoo' }, commit: 'Update Account' }
    assert_response :success
    assert flash[:alert].present?
    assert flash[:old].present?
  end

  test 'text parse: should be setup properly' do
    get textparse_path
    assert_select 'title', 'BYS Web Sandbox: Text Parser'

    assert_select 'select[id=?]', 'input_form_request_ID'

    @requestIDs.each do |id|
      assert_select 'option[value=?]', id
    end

    assert_select 'input[value=?]', 'Submit XML'
    assert_select 'input[value=?]', 'Submit JSON'
  end
end

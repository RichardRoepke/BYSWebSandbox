require 'test_helper'

class AdminServicesControllerTest < ActionDispatch::IntegrationTest
  def setup
    sign_in users(:admin)
  end

  test 'redirect when not signed in as a admin' do
    get admin_path
    assert_response :success

    sign_out users(:admin)
    sign_in users(:one)

    get admin_path
    assert_response :found
    assert_redirected_to root_path
    assert flash[:alert].present?

    sign_out users(:one)
    get admin_path
    assert_response :found
    assert_redirected_to new_user_session_path
    assert flash[:alert].present?
  end

  # Testing creating new users is done in user_controller_test.rb
  test 'new user renders properly' do
    get admin_newuser_path, params: { email: 'testing@test.com', admin: '1', security: 'present', password: 'foobar', password_confirmation: 'foobar'}
    assert_response :success
    assert_select 'input[value=?]', 'testing@test.com'
    assert_select 'input[value=?]', '1'
    assert_select 'input[value=?]', 'present'
    assert_select 'input[value=?]', 'foobar', count: 0
  end
end

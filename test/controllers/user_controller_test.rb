require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  def setup
    sign_in users(:admin)
  end

  test 'redirect if not admin' do
    get admin_user_index_path
    assert_response :success

    sign_out users(:admin)
    get admin_user_index_path
    assert_response :found
    assert_redirected_to new_user_session_path

    sign_in users(:one)
    get admin_user_index_path
    assert_response :found
    assert_redirected_to root_path
  end

  test 'can create new user' do
    get new_admin_user_path, params: { user: { email: 'unique@example.org',
                                               security: nil,
                                               admin: '0',
                                               password: 'foobar',
                                               password_confirmation: 'foobar' } }
    assert_response :found
    assert flash[:success].present?
    assert_redirected_to admin_path
  end

  test 'cannot create invalid user' do
    get new_admin_user_path, params: { user: { email: 'one@example.org',
                                               security: nil,
                                               admin: '0',
                                               password: 'foobar',
                                               password_confirmation: 'barfoo' } }
    assert_response :found
    assert flash[:alert].present?
    assert_redirected_to admin_newuser_path
  end


end

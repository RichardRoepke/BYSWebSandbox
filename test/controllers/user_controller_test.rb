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
    assert_redirected_to %r(admin/newuser\?admin=0&email=one%40example.org) #Ensuring that params are passed
  end

  test 'index renders properly' do
    get admin_user_index_path
    assert_response :success
    # 3 users with edit, delete, promote, 1 user with edit only, and the 5 buttons in the banner.
    assert_select 'a[href]', count: 15
  end

  test 'can update user' do
    patch admin_user_path(1), params: { user: { security: 'new' },
                                        commit: 'Update',
                                        id: '1'}
    assert_response :found
    assert_redirected_to admin_user_index_path
    assert flash[:success].present?

    user = User.find(1)
    assert user.security == 'new'
    assert_not user.security == 'present'
  end

  test 'cannot update user with invalid values' do
    patch admin_user_path(1), params: { user: { security: 'new',
                                                password: 'foobar',
                                                password_confirmation: 'barfoo' },
                                        commit: 'Update',
                                        id: '1'}
    assert_response :found
    assert_redirected_to root_path # Going to the fallback path, since no back exists.
    assert flash[:alert].present?

    user = User.find(1)
    assert_not user.security == 'new'
    assert user.security == 'present'
  end

  test 'can destory users' do
    delete admin_user_path(1)
    assert_response :found
    assert_redirected_to root_path # Going to the fallback path, since no back exists.
    assert flash[:success].present?
  end

  test 'cannot delete user that does not exist' do
    delete admin_user_path(49)
    assert_response :found
    assert flash[:alert].present?
  end

  test 'cannot delete currently logged in user' do
    delete admin_user_path(4)
    assert_response :found
    assert flash[:alert].present?
  end

  test 'can promote and demote user' do
    get admin_user_promote_path(1)
    assert_response :found
    assert flash[:success].present?

    user = User.find(1)
    assert user.admin

    get admin_user_demote_path(1)
    assert_response :found
    assert flash[:success].present?

    user = User.find(1)
    assert_not user.admin
  end

  test 'cannot demote currently logged in user' do
    get admin_user_demote_path(4)
    assert_response :found
    assert flash[:alert].present?

    user = User.find(4)
    assert user.admin
  end

end

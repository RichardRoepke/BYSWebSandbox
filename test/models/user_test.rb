require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user email must be unique' do
    user = User.create({email: 'jimmy@example.org', encrypted_password: 'foobar', admin: false})
    assert_not user.save
  end

  test 'user email and password must be present' do
    user = User.create({email: 'unique@example.org', encrypted_password: '', admin: false})
    assert_not user.save

    user = User.create({email: '', encrypted_password: 'foobar', admin: false})
    assert_not user.save
  end
end

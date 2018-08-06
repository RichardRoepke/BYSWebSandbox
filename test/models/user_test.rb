require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user email must be unique' do
    test = User.create({email: 'jimmy@example.org', encrypted_password: 'foobar', admin: false})
    assert_not test.save
  end

  test 'user email and password must be present' do
    test = User.create({email: 'unique@example.org', encrypted_password: '', admin: false})
    assert_not test.save

    test = User.create({email: '', encrypted_password: 'foobar', admin: false})
    assert_not test.save
  end
end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create!({email: 'admin@admin.org', password: 'asdfasdf', password_confirmation: 'asdfasdf', confirmed_at: Time.zone.now, admin: true, security: 'Yes'})
User.create!({email: 'user@user.org', password: 'asdfasdf', password_confirmation: 'asdfasdf', confirmed_at: Time.zone.now, admin: false, security: 'No'})

50.times do |num|
  User.create!({email: num.to_s + '@number.org', password: 'asdfasdf', password_confirmation: 'asdfasdf', admin: false, security: 'Testing ' + num.to_s})
end
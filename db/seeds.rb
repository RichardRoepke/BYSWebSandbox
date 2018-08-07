# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create!({email: 'admin@admin.org', password: 'asdfasdf', password_confirmation: 'asdfasdf', confirmed_at: Time.zone.now, admin: true, security: 'Yes'})
User.create!({email: 'user@user.org', password: 'asdfasdf', password_confirmation: 'asdfasdf', confirmed_at: Time.zone.now, admin: false, security: 'No'})

100.times do |num|
  mail = (0...(3 + rand(12))).map { (65 + rand(26)).chr }.join
  User.create!({email: 'SEED_' + mail + '@jibberish.org', password: 'asdfasdf', password_confirmation: 'asdfasdf', admin: false, security: 'Testing'})
end
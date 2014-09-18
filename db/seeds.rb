# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

(1..10).each do
  Post.create([{title: Faker::Company.bs, body: Faker::Lorem.sentences.join(' ')}])
end

User.create(email: 'joe@example.org', password: 'letmein')
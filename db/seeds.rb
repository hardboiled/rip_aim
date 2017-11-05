# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

return unless ['development', 'qa'].include?(Rails.env)

prefix = 'myusername'
return if User.username_starts_with(prefix).count > 0

users = (1..10).to_a.map do |i|
  User.create!(username: "#{prefix}#{i}", password: 'passw0rd')
end

users.each do |sender|
  potential_recipients = users - [sender]
  50.times do
    my_index = rand(1..potential_recipients.length) - 1
    recipient = potential_recipients[my_index]
    Message.create!(
      sender: sender, recipient: recipient, content: 'I <3 swimming',
      message_type: 'text', metadata: '{ "tags": [ "my_fair_lady", "jovial", "that_sunset_tho" ] }'
    )
  end
end

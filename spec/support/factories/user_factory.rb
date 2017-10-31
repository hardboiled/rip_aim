FactoryGirl.define do
  factory :user do
    sequence(:username) {|n| "jane_doe#{n}" }
    password 'hihihihi8'
  end
end

FactoryGirl.define do
  factory :message do
    content 'this is content'
    message_type 'text'

    before(:create) do |message|
      message.sender ||= FactoryGirl.create(:user, id: SecureRandom.uuid)
      message.recipient ||= FactoryGirl.create(:user, id: SecureRandom.uuid)
    end
  end
end

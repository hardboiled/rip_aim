require 'rails_helper'

RSpec.describe Message, type: :model do
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:message_type) }
  it { should validate_presence_of(:sender) }
  it { should validate_presence_of(:recipient) }

  let(:valid_message_types) { %i[text image_link video_link] }

  it 'should allow valid message types' do
    valid_message_types.each do |message_type|
      message = Message.new(message_type: message_type)
      message.valid?
      expect(message.errors).to_not include('message_type')
    end
  end

  it 'should not allow invalid message types' do
    expect do
      Message.new(content: 'blah', message_type: 'not a valid message type')
    end.to raise_error(/message_type/)
  end

  it 'should not allow sender to equal recipient' do
    sender = FactoryGirl.create(:user)
    message = Message.new(content: 'blah', message_type: valid_message_types.first)
    message.sender = message.recipient = sender
    message.valid?
    expect(message.errors).to include('recipient')
  end
end

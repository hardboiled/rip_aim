require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  render_views

  describe '#create' do
    before(:each) do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
    end

    it 'should create a message with valid params' do
      expect do
        post :create, params: {
          sender_id: @user1.id, recipient_id: @user2.id,
          content: 'hihi', message_type: 'text',
          metadata: '{ "tags": [ "my_fair_lady", "jovial", "that_sunset_tho" ] }'
        }, format: :json
        expect(response).to have_http_status(:created)
      end.to change(Message, :count).by(1)
    end

    it 'should return errors with invalid params' do
      expect do
        post :create, params: {
          sender_id: @user1.id, recipient_id: @user1.id,
          content: 'hihi', message_type: 'text',
          metadata: '{ "tags": [ "my_fair_lady", "jovial", "that_sunset_tho" ] }'
        }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']['validations']).to include('recipient_id')
      end.to change(Message, :count).by(0)
    end
  end

  describe '#index' do
    it 'should support pagination with limit and page' do
      message = FactoryGirl.create(:message)
      49.times do
        FactoryGirl.create(:message, sender: message.sender, recipient: message.recipient)
      end
      messages = Message.between_users(message.sender, message.recipient).limit(10).offset(20)

      get :index, params: {
        users: [message.sender.id, message.recipient.id],
        limit: 10,
        page: 2
      }, format: :json

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['limit']).to eq(10)
      expect(body['page']).to eq(2)
      expect(body['total']).to eq(50)
      expect(
        messages.map { |x| x.sender.id }
      ).to match_array(body['data'].map { |x| x['sender_id'] })
    end

    it 'should default to 100 records' do
      message = FactoryGirl.create(:message)
      user_ids = [message.sender.id, message.recipient.id]
      get :index, params: { users: user_ids }, format: :json
      expect(JSON.parse(response.body)).to match(hash_including('limit' => 100))
    end

    it 'should return empty array for two users that exist' do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      get :index, params:  { users: [user1.id, user2.id] }, format: :json
      body = JSON.parse(response.body)
      expect(body['data']).to eq([])
      expect(body['total']).to eq(0)
      expect(body['limit']).to eq(100)
      expect(body['page']).to eq(0)
      expect(response).to have_http_status(:ok)
    end

    it 'should require two users' do
      get :index, params: { users: [SecureRandom.uuid] }, format: :json
      body = JSON.parse(response.body)
      expect(body['error']['message']).to match(/two\s+users/)
      expect(response).to have_http_status(:bad_request)
    end

    it 'should 404 if one or both users don\'t exist' do
      message = FactoryGirl.create(:message)
      user_ids = [message.sender.id, SecureRandom.uuid]
      get :index, params: { users: user_ids }, format: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end

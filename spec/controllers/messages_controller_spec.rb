require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  include RequestHelper

  render_views

  describe '#create' do
    def valid_params(user1, user2 = nil)
      {
        sender_id: user1, recipient_id: user2,
        content: 'hihi', message_type: 'text',
        metadata: '{ "tags": [ "my_fair_lady", "jovial", "that_sunset_tho" ] }'
      }.compact
    end

    it_behaves_like 'a user authenticated endpoint' do
      let(:user) { FactoryGirl.create(:user) }
      let(:execute_request) do
        lambda do
          recipient = FactoryGirl.create(:user)
          my_params = valid_params(user.id, recipient.id)
          post :create, { params: my_params }.merge(format: :json)
        end
      end
    end

    before(:each) do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
    end

    it 'should create a message with valid params' do
      expect do
        auth_post :create, { params: valid_params(@user1.id, @user2.id) }, @user1.id
        expect(response).to have_http_status(:created)
      end.to change(Message, :count).by(1)
    end

    it 'should return errors with invalid params' do
      expect do
        auth_post :create, { params: valid_params(@user1.id, @user1.id) }, @user1.id
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']['validations']).to include('recipient_id')
      end.to change(Message, :count).by(0)
    end

    it 'should not allow sender to create messages on behalf of another sender' do
      @user3 = FactoryGirl.create(:user)
      auth_post :create, { params: valid_params(@user1.id, @user2.id) }, @user3.id
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '#index' do
    def valid_params(sender_id, recipient_id = nil, limit = nil, page = nil)
      {
        sender_id: sender_id,
        recipient_id: recipient_id,
        limit: limit,
        page: page
      }.compact
    end

    it_behaves_like 'a user authenticated endpoint' do
      let(:user) { FactoryGirl.create(:user) }
      let(:execute_request) do
        lambda do
          recipient = FactoryGirl.create(:user)
          my_params = valid_params(user.id, recipient.id)
          get :index, { params: my_params }.merge(format: :json)
        end
      end
    end

    it 'should support pagination with limit and page' do
      message = FactoryGirl.create(:message)
      49.times do
        FactoryGirl.create(:message, sender: message.sender, recipient: message.recipient)
      end
      messages = Message.between_users(message.sender, message.recipient).limit(10).offset(20)

      auth_get :index, {
        params: valid_params(message.sender.id, message.recipient.id, 10, 2)
      }, message.sender.id

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
      auth_get :index, { params: valid_params(message.sender.id, message.recipient.id) },
        message.sender.id
      expect(JSON.parse(response.body)).to match(hash_including('limit' => 100))
    end

    it 'should return empty array for two users that exist' do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      auth_get :index, { params: valid_params(user1.id, user2.id) }, user1.id
      body = JSON.parse(response.body)
      expect(body['data']).to eq([])
      expect(body['total']).to eq(0)
      expect(body['limit']).to eq(100)
      expect(body['page']).to eq(0)
      expect(response).to have_http_status(:ok)
    end

    it 'should require recipient_id' do
      user = FactoryGirl.create(:user)
      auth_get :index, { params: valid_params(user.id) }, user.id
      body = JSON.parse(response.body)
      expect(body['error']['message']).to include('recipient_id')
      expect(response).to have_http_status(:bad_request)
    end

    it 'should 404 if one or both users don\'t exist' do
      user = FactoryGirl.create(:user)
      auth_get :index, { params: valid_params(user.id, SecureRandom.uuid) }, user.id
      expect(response).to have_http_status(:not_found)
    end

    it 'should not allow sender to read messages of another sender' do
      message = FactoryGirl.create(:message)
      @user3 = FactoryGirl.create(:user)
      auth_get :index, { params: valid_params(message.sender.id, message.recipient.id) }, @user3.id
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

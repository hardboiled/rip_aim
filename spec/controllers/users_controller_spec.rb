require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include RequestHelper

  render_views

  describe '#show' do
    it_behaves_like 'a user authenticated endpoint' do
      let(:user) { FactoryGirl.create(:user) }
      let(:execute_request) do
        lambda do
          get :show, { params: { id: user.id } }.merge(format: :json)
        end
      end
    end

    it 'should return success for valid user' do
      user = FactoryGirl.create(:user)
      expected_response = {
        'id' => user.id, 'username' => user.username,
        'created_at' => anything, 'updated_at' => anything
      }
      auth_get :show, { params: { id: user.id } }, user.id
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match(expected_response)
    end

    it 'should not allow a user to access another user\'s data' do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      auth_get :show, { params: { id: user1.id } }, user2.id
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '#create' do
    it 'should return success with valid params and login user' do
      request_params = { username: 'blahsdf33', password: 'hihihihi8' }
      expect do
        post :create, params: request_params, format: :json
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to match(
          hash_including('id' => anything, 'username' => 'blahsdf33')
        )
      end.to change(User, :count).by(1)
      expect(session[:current_user_id]).to_not be(nil)
    end
    it 'should return errors with invalid params' do
      request_params = { password: 'hihihihi8' }
      post :create, params: request_params, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']['validations']).to include('username')
    end
  end

  describe '#update' do
    def valid_params(user_id, username = nil)
      {
        id: user_id,
        username: username
      }.compact
    end

    it_behaves_like 'a user authenticated endpoint' do
      let(:user) { FactoryGirl.create(:user) }
      let(:execute_request) do
        lambda do
          new_username = "#{user.username}_1"
          my_params = valid_params(user.id, new_username)
          patch :update, { params: my_params }.merge(format: :json)
        end
      end
    end

    it 'should return success for valid user' do
      user = FactoryGirl.create(:user)
      new_username = "#{user.username}_1"
      expected_response = {
        'id' => user.id, 'username' => new_username,
        'created_at' => anything, 'updated_at' => anything
      }
      auth_patch :update, { params: valid_params(user.id, new_username) }, user.id
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match(expected_response)
    end
  end

  describe '#index' do
    let(:user) { FactoryGirl.create(:user) }

    def valid_params(username_prefix, limit = nil, page = nil)
      {
        search_prefix: username_prefix,
        limit: limit,
        page: page
      }.compact
    end

    it_behaves_like 'a user authenticated endpoint' do
      let(:user) { FactoryGirl.create(:user) }
      let(:execute_request) do
        lambda do
          my_params = valid_params('hello')
          get :index, { params: my_params }.merge(format: :json)
        end
      end
    end

    it 'should require search_prefix' do
      auth_get :index, {}, user.id
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']['message']).to match(/search_prefix/)
    end

    it 'should support pagination with limit and page' do
      prefix = 'mylovelytestuser'
      (1..50).to_a.map do |i|
        FactoryGirl.create(:user, username: "#{prefix}#{i}")
      end
      users = User.username_starts_with(prefix)

      auth_get :index, {
        params: valid_params(prefix, 10, 2)
      }, users.first.id

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['limit']).to eq(10)
      expect(body['page']).to eq(2)
      expect(body['total']).to eq(users.count)
      limited_users = users.limit(10).offset(20)
      expect(
        limited_users.map(&:id)
      ).to match_array(body['data'].map { |x| x['id'] })
    end
  end
end

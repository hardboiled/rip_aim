require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  describe '#show' do
    it 'should return success for valid user' do
      user = FactoryGirl.create(:user)
      expected_response = { 'id' => user.id, 'username' => user.username }
      get :show, params: { id: user.id }, format: :json
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match(expected_response)
    end

    it 'should return not found for missing user' do
      get :show, params: { id: SecureRandom.uuid }, format: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe '#create' do
    it 'should return success with valid params' do
      request_params = { username: 'blah', password: 'hihihihi8' }
      post :create, params: request_params, format: :json
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to match(hash_including('id' => anything, 'username' => 'blah'))
    end

    it 'should return errors with invalid params' do
      request_params = { password: 'hihihihi8' }
      post :create, params: request_params, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']['validations']).to include('username')
    end
  end

  describe '#update' do
    it 'should return success for valid user' do
      user = FactoryGirl.create(:user)
      new_username = "#{user.username}_1"
      expected_response = { 'id' => user.id, 'username' => new_username }
      patch :update, params: { id: user.id, username: new_username }, format: :json
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match(expected_response)
    end

    it 'should return not found for missing user' do
      patch :update, params: { id: SecureRandom.uuid, username: 'hi' }, format: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end

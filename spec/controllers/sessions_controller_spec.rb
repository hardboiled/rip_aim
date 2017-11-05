require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe '#login' do
    it 'should login the user' do
      password = 'hihihihihi88'
      user = FactoryGirl.create(:user, password: password)
      post :login, params: { username: user.username, password: password }, format: :json
      expect(response).to have_http_status(:ok)
      expect(subject).to render_template('users/show')
      expect(session[:current_user_id]).to eq(user.id)
    end

    it 'should not login a user with invalid credentials' do
      password = 'hihihihihi88'
      user = FactoryGirl.create(:user, password: password)
      post :login, params: { username: user.username, password: 'incorrect' }, format: :json
      expect(response).to have_http_status(:unauthorized)
      expect(session[:current_user_id]).to be(nil)
    end

    it 'should return unauthorize for invalid user' do
      password = 'hihihihihi88'
      user = FactoryGirl.create(:user, password: password)
      post :login, params: { username: "#{user.username}00", password: 'incorrect' }, format: :json
      expect(response).to have_http_status(:unauthorized)
      expect(session[:current_user_id]).to be(nil)
    end
  end

  describe '#logout' do
    it 'should logout the user' do
      session[:current_user_id] = SecureRandom.uuid
      get :logout
      expect(response).to have_http_status(:no_content)
      expect(session[:current_user_id]).to be(nil)
    end
  end
end

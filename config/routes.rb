Rails.application.routes.draw do
  scope 'v1' do
   resources :users, only: %i[show create update]
   resources :messages, only: %i[index create]
  end
end

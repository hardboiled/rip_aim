Rails.application.routes.draw do
  scope 'v1' do
   resources :users, only: %i[show create update index]
   scope '/:sender_id' do
     post 'messages', to: 'messages#create'
     get '/messages', to: 'messages#index'
   end
   post 'sessions/login'
   get 'sessions/logout'
  end
end

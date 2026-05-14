# config/routes.rb
Rails.application.routes.draw do
  resources :movies do
    collection do
      get :search
      get :popular
    end
  end

  resources :users
  resources :sessions, only: [:new, :create, :destroy]

  get 'signup', to: 'users#new'
  get 'login',  to: 'sessions#new'
  delete 'logout', to: 'sessions#destroy'

  # Для тестування Sentry
  get '/test_sentry', to: 'application#test_sentry'

  root "movies#index"
end
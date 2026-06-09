# config/routes.rb
Rails.application.routes.draw do
  root "pages#welcome"

  get  "login",  to: "sessions#new"
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get  "signup", to: "users#new"
  post "signup", to: "users#create"

  resources :users, only: [:show]

  resources :movies, only: [:index, :show, :new, :create] do
    resources :comments, only: [:create, :destroy]
    resource :rating, only: [:create]

    collection do
      get :search
      get :popular
    end
  end

  resources :watchlists, only: [:index, :create, :destroy]
  resources :movie_reactions, only: [:destroy]
  resources :swipes, only: [:index, :create]
  get "randomizer", to: "randomizer#index"
  get "collections/:token", to: "collections#show", as: :shared_collection

  namespace :admin do
    root "dashboard#index"
    resources :movies, only: [:new, :create, :destroy]
  end

  get "catalog", to: "movies#index"
  get "my_list", to: "users#show"
  get "match", to: "swipes#index"
end

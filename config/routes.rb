Rails.application.routes.draw do
  resources :movies do
    collection do
      get :search
      get :popular
    end
  e.nd
end
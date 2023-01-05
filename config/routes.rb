Rails.application.routes.draw do
  resources :home
  resources :users
  root "home#index"
end

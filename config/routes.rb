Rails.application.routes.draw do
  resources :home
  resources :users
  get "/departments/:id", to: "departments#index"
  get "/users/:id", to: "users#show"
  
  resources :departments do 
    resources :users
  end 
  
  root "home#index"
end

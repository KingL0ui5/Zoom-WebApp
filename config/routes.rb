Rails.application.routes.draw do
  resources :home
  resources :users
  resources :departments
  get "/departments/:id", to: "departments#show"
  get "/users/:id", to: "users#show"
  
  resources :departments do 
    resources :users
  end 
  
  root "home#index"
end

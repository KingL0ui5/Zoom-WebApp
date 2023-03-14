Rails.application.routes.draw do
  resources :home
  resources :users
  resources :departments
  
  get "/departments/:id", to: "departments#show"
  get "/users/:id", to: "users#show"
  
  get '/zooms2s/new_meeting', to: 'zooms2s#new_meeting' #for S2S procedures
  get '/zooms2s', to: 'zooms2s#authorise' 
  
  get '/zoom/callback', to: 'zoom#callback' #for normal OAuth procedures 
  get '/zoom', to: 'zoom#index'
  
  resources :departments do 
    resources :users
  end 
  
  root "home#index"
end

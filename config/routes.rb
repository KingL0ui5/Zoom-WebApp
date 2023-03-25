Rails.application.routes.draw do
  resources :home
  resources :users
  resources :departments
  get "/csrf_js", to: 'application#csrf_meta_tags'  #for csrf requests
  
  get '/login', to: "sessions#new" #for logins
  post '/login', to: "sessions#create"
  delete '/logout', to: "sessions#destroy"
  
  get "/departments/:id", to: "departments#show"
  patch "/departments", to: "departments#update"
  
  get "/users/:id", to: "users#show"
  patch "/users", to: "users#update"

  get '/zooms2s/new_meeting', to: 'zooms2s#new_meeting' #for S2S procedures
  post '/zooms2s/create_meeting', to: 'zooms2s#create_meeting'
  #get '/zooms2s/authorise', to: 'zooms2s#authorise' 
  
  get '/zoom/callback', to: 'zoom#callback' #for normal OAuth procedures 
  get '/zoom', to: 'zoom#index'
  
  resources :departments do 
    resources :users
  end 
  
  root "home#index"
end

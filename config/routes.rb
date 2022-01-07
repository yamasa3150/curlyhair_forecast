Rails.application.routes.draw do
  resources :settings, only: %i[new edit create update]
  resources :users, only: %i[create]

  root 'top#index'
  post '/callback' => 'line_bot#callback'
  get '/new_setting' => 'settings#new_setting'
  get '/edit_setting' => 'settings#edit_setting'
  get '/setting' => 'settings#setting'
end

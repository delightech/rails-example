Rails.application.routes.draw do
  namespace :staff do
    root "top#index"
    # HTTPメソッド URLパス Controller#Action 別名
    get "login" => "sessions#new", as: :login
    post "session" => "sessions#create", as: :session
    delete "session" => "sessions#destroy"
  end
  namespace :admin do
    root "top#index"
    get "login" => "sessions#new", as: :login
    post "session" => "sessions#create", as: :session
    delete "session" => "sessions#destroy"
  end
  namespace :customer do
    root "top#index"
  end
end

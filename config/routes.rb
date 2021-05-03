Rails.application.routes.draw do
  namespace :staff, path: "" do
    root "top#index"
    # HTTPメソッド URLパス Controller#Action 別名
    get "login" => "sessions#new", as: :login
    # sessionはユーザーに一つなので単数リソースで表現可能
    resource :session, only: [:create, :destroy]
    # スタッフ画面（ユーザー個人利用）に新規作成、削除は不要のためresourceメソッドから除外する
    resource :account, except: [:new, :create, :destroy]
  end
  namespace :admin do
    root "top#index"
    get "login" => "sessions#new", as: :login
    # sessionはユーザーに一つなので単数リソースで表現可能
    resource :session, only: [:create, :destroy]
    resources :staff_members
  end
  namespace :customer do
    root "top#index"
  end
end

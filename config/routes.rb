Rails.application.routes.draw do
  # config/initializers/baukis2.rb で初期化時に設定された内容を取得する
  config = Rails.application.config.baukis2

  # ホスト名に制約を設ける
  # 指定したホスト名でアクセスされた場合にのみstaffトップページが表示される
  constraints host: config[:staff][:host] do
    namespace :staff, path: config[:staff][:path] do
      root "top#index"
      # HTTPメソッド URLパス Controller#Action 別名
      get "login" => "sessions#new", as: :login
      # sessionはユーザーに一つなので単数リソースで表現可能
      resource :session, only: [:create, :destroy]
      # スタッフ画面（ユーザー個人利用）に新規作成、削除は不要のためresourceメソッドから除外する
      resource :account, except: [:new, :create, :destroy]
    end
  end
  constraints host: config[:admin][:host] do
    namespace :admin do
      # rootは、/admin以降のパスはなしで、TopControllerクラスのindexアクションが呼ばれる
      # rootは、link_toに指定する際は :admin_root で遷移先指定する
      root "top#index"
      get "login" => "sessions#new", as: :login
      # sessionはユーザーに一つなので単数リソースで表現可能
      resource :session, only: [:create, :destroy]
      resources :staff_members do
        # nested resources
        # HTTPメソッド: GET
        # urlパス: /admin/staff_members/:staff_member_id/staff_events
        # アクション: index
        # ルーティング名: :admin_staff_member_staff_events
        # このリソースでスタッフ個別のログイン・ログアウト記録の表示に限定している
        resources :staff_events, only: [:index]
      end
      # 全ての職員のログイン・ログアウト記録を閲覧するためのリソース
      # HTTPメソッド: GET
      # urlパス: /admin/staff_events
      # アクション: index
      # ルーティング名: :admin_staff_events
      resources :staff_events, only: [:index]
    end
  end
  constraints host: config[:customer][:host] do
    namespace :customer, path: config[:customer][:path] do
      root "top#index"
    end
  end
end

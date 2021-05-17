class Admin::Base < ApplicationController
  # アクション実行前に実行するメソッドを指定
  before_action :authorize

  private def current_administrator
    # cookieにadministrator_idが保持されていた場合、DBからデータを引く
    if session[:administrator_id]
      @current_administrator ||= Administrator.find_by(id: session[:administrator_id])
    end
  end

  helper_method :current_administrator

  private def authorize
    # ログインしていなければあログイン画面へリダイレクトする
    unless current_administrator
      flash.alert = "管理者としてログインしてください。"
      redirect_to :admin_login
    end
  end
end

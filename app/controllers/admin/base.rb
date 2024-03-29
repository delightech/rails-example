class Admin::Base < ApplicationController
  # アクション実行前に実行するメソッドを指定
  before_action :authorize
  before_action :check_account
  before_action :check_timeout

  private def current_administrator
    # cookieにadministrator_idが保持されていた場合、DBからデータを引く
    if session[:administrator_id]
      @current_administrator ||= Administrator.find_by(id: session[:administrator_id])
    end
  end

  helper_method :current_administrator

  private def authorize
    # ログインしていなければログイン画面へリダイレクトする
    unless current_administrator
      flash.alert = "管理者としてログインしてください。"
      redirect_to :admin_login
    end
  end

  private def check_account
    if current_administrator && !current_administrator.active?
      session.delete(:administrator_id)
      flash.alert = "アカウントが無効になりました。"
      redirect_to :admin_root
    end
  end

  TIMEOUT = 60.minutes

  private def check_timeout
    if current_administrator
      if session[:last_access_time] >= TIMEOUT.ago
        session[:last_access_time] = Time.current
      else
        session.delete(:administrator_id)
        flash.alert = "セッションがタイムアウトしました。"
        redirect_to :admin_root
      end
    else
    end
  end
end

class Staff::Base < ApplicationController
  before_action :authorize
  before_action :check_account
  before_action :check_timeout

  private def current_staff_member
    if session[:staff_member_id]
      @current_staff_member ||= StaffMember.find_by(id: session[:staff_member_id])
      @current_staff_member
    end
  end

  helper_method :current_staff_member

  private def authorize
    unless current_staff_member
      flash.alert = '職員としてログインしてください。'
      redirect_to :staff_login
    end
  end

  private def check_account
    # activeでなくなったアカウントは強制的にログアウトさせる

    # ここでtryを使わないのは、current_staff_memberがnilの場合（未ログイン時）は強制ログアウト&リダイレクトさせないため
    # 以下の書き方だと、未ログイン時もactive?がfalseでも同じfalseとしてif文を通過してしまう(リダイレクトループになってしまう)
    # if !current_staff_member.try(:active?)
    if current_staff_member && !current_staff_member.active?
      session.delete(:staff_member_id)
      flash.alert = "アカウントが無効になりました。"
      redirect_to :staff_root
    end
  end

  TIMEOUT = 60.minutes

  private def check_timeout
    if current_staff_member
      # 最終session作成時刻が、現在の時刻から1時間前の時刻より後(1時間以内)なら、有効なsessionとして最終session時刻を更新する
      if session[:last_access_time] >= TIMEOUT.ago
        session[:last_access_time] = Time.current
      else
        session.delete(:staff_member_id)
        flash.alert = "セッションがタイムアウトしました。"
        redirect_to :staff_login
      end
    end
  end
end

class Staff::SessionsController < Staff::Base
  skip_before_action :authorize

  def new
    if current_staff_member
      redirect_to :staff_root
    else
      @form = Staff::LoginForm.new
      render action: "new"
    end
  end

  def create
    @form = Staff::LoginForm.new(login_form_params)
    if @form.email.present?
      staff_member = StaffMember.find_by("LOWER(email) = ?", @form.email.downcase)
    end
    # DBから取得したhashed_passwordと入力されたパスワードのハッシュ値が同じかをチェックする
    if Staff::Authenticator.new(staff_member).authenticate(@form.password)
      if staff_member.suspended?
        # StaffEvent.typeを上書きしてDB更新
        staff_member.events.create!(type: "rejected")
        # 以下でも同じ
        # StaffEvent.create!(member: staff_member, type: "rejected")

        # flash.now.*は直後のView表示時まで有効
        flash.now.alert = "アカウントが停止されています。"
        render action: "new"
      else
        session[:staff_member_id] = staff_member.id
        session[:last_access_time] = Time.current
        # StaffEvent.typeを上書きしてDB更新
        staff_member.events.create!(type: "logged_in")
        # 以下でも同じ
        # StaffEvent.create!(member: staff_member, type: "rejected")

        # flash.noticeは次のアクションまで有効(redirect_toで指定した先のアクションでも有効)
        flash.notice = "ログインしました。"
        redirect_to :staff_root
      end
    else
      # flash.now.noticeはこのアクションまで有効
      # viewに指定されたstaff/sessions/new.html.erbでのみ表示される
      flash.now.alert = "メールアドレスまたはパスワードが正しくありません。"
      render action: "new"
    end
  end

  private def login_form_params
    params.require(:staff_login_form).permit(:email, :password)
  end

  def destroy
    if current_staff_member
      current_staff_member.events.create!(type: "logged_out")
    end
    session.delete(:staff_member_id)
    flash.notice = "ログアウトしました。"
    redirect_to :staff_root
  end
end

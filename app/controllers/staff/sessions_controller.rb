class Staff::SessionsController < Staff::Base
  def new
    if current_staff_member
      redirect_to :staff_root
    else
      @form = Staff::LoginForm.new
      render action: "new"
    end
  end

  def create
    pp params
    @form = Staff::LoginForm.new(params[:staff_login_form])
    if @form.email.present?
      staff_member = StaffMember.find_by("LOWER(email) = ?", @form.email.downcase)
    end
    pp staff_member
    # DBから取得したhashed_passwordと入力されたパスワードのハッシュ値が同じかをチェックする
    if Staff::Authenticator.new(staff_member).authenticate(@form.password)
      if staff_member.suspended?
        # flash.now.*は直後のView表示時まで有効
        flash.now.alert = "アカウントが停止されています。"
        render action: "new"
      else
        session[:staff_member_id] = staff_member.id
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

  def destroy
    session.delete(:staff_member_id)
    flash.notice = "ログアウトしました。"
    redirect_to :staff_root
  end
end
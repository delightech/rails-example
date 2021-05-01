class Admin::SessionsController < Admin::Base
  def new
    # current_administratorメソッドはAdmin::Baseに定義されている
    if current_administrator
      # ログイン済みなら、adminトップページへリダイレクトする
      redirect_to :admin_root
    else
      # 未ログインなら、ログインフォーム（new view）をレンダリングする
      @form = Admin::LoginForm.new
      render action: "new"
    end
  end

  def create
    pp params
    # formから送信されてくるadmin_login_formオブジェクトをparamsオブジェクトから取り出し、
    # Admin::LoginFormクラスに持たせる
    if (@form = Admin::LoginForm.new(params[:admin_login_form])).email.present?
      administrator = Administrator.find_by("LOWER(email) = ?", @form.email.downcase)
    end
    pp administrator
    if Admin::Authenticator.new(administrator).authenticate(@form.password)
      if administrator.suspended?
        flash.now.alert = "アカウントが停止されています"
        render action: "new"
      else
        session[:administrator_id] = administrator.id
        flash.notice = "ログインしました"
        redirect_to :admin_root
      end
    else
      flash.now.alert = "メールアドレスまたはパスワードが正しくありません。"
      render action: "new"
    end
  end

  def destroy
    session.delete(:administrator_id)
    flash.notice = "ログアウトしました。"
    redirect_to :admin_root
  end
end

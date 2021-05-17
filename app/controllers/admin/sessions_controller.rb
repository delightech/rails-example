class Admin::SessionsController < Admin::Base
  # トップページを表示するのにログインは不要なのでスキップする
  skip_before_action :authorize

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
    # formから送信されてくるadmin_login_formオブジェクトをparamsオブジェクトから取り出し、
    # Admin::LoginFormクラスに持たせる

    # Strong Parametersを無効にしている場合、下記のようにparamsから直接formモデルの値を取得が可能
    # しかしセキュリティ上の問題から、通常Strong Parametersは有効にすべき
    #if (@form = Admin::LoginForm.new(params[:admin_login_form])).email.present?

    # Strong Parametersが有効（デフォルト）の場合の実装
    if (@form = Admin::LoginForm.new(login_form_params)).email.present?

      administrator = Administrator.find_by("LOWER(email) = ?", @form.email.downcase)
    end
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

  private def login_form_params
    # Strong Parameters
    # 許可パラメータを指定し、入力を限定する
    # params.requireでparamsオブジェクトが:admin_login_formというキーを持っているかどうかをチェックしている
    # 持っていなければActionController::ParameterMissingエラーが発生する
    # requireの戻り値はActionController::Parametersクラス（Hashの子孫）
    # requireは指定されたキーに対応する値を返す。
    # permitは指定されたパラメータ以外を除去する。ここでは:emailと:passwordのみ有効としている
    # permitを通さずにparamsオブジェクトの値をそのままモデルオブジェクトのassign_attributesメソッドに渡すとActiveModel::ForbiddenAttributesErrorが発生する
    # permitを通した場合、指定したパラメータ以外は無視される
    params.require(:admin_login_form).permit(:email, :password)
  end

  def destroy
    session.delete(:administrator_id)
    flash.notice = "ログアウトしました。"
    redirect_to :admin_root
  end
end

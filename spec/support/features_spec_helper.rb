module FeaturesSpecHelper
  def switch_namespace(namespace)
    config = Rails.application.config.baukis2
    Capybara.app_host = "http://" + config[namespace][:host]
  end

  def login_as_staff_member(staff_member, password = "pw")
    visit staff_login_path
    # 上記は以下のようにも書けるが、ルーティングの変更に対応できるように、上記のようにヘルパーメソッドを使っておく方が良い
    # visit "/login"

    # withinでHTMLの対象範囲を絞り込んでいる。この内側がCapybaraによる操作対象
    # #login-formはCSSセレクタ
    within("#login-form") do
      # fill_inの第一引数はラベル文字列、withオプションで指定しているのは入力する値
      # fill_inの第一引数には下記のようにid属性、name属性での指定が可能
      # id属性
      # fill_in "staff_login_form_email", with: staff_member.email
      # name属性
      # fill_in "staff_login_form[email]", with: staff_member.email
      fill_in "メールアドレス", with: staff_member.email
      fill_in "パスワード", with: password
      # click_buttonの引数にはラベル文字列かid属性の値を指定可能
      click_button "ログイン"
    end
  end
end
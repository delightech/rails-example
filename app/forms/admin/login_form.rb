class Admin::LoginForm
  # ActiveModel::Modelをincludeすることで、
  # form_withで使えるDBと紐付かないモデルを作成可能になる
  include ActiveModel::Model

  attr_accessor :email, :password
end
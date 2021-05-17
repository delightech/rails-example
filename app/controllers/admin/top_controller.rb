class Admin::TopController < Admin::Base
  # トップページを表示するのにログインは不要なのでスキップする
  skip_before_action :authorize

  def index
    if current_administrator
      render action: "dashboard"
    else
      render action: "index"
    end
  end
end

class ApplicationController < ActionController::Base
  layout :set_layout

  class Forbidden < ActionController::ActionControllerError; end
  class IpAddressRejected < ActionController::ActionControllerError; end

  # include app/controllers/concerns/error_handers.rb
  # ErrorHandlersモジュールで定義した関数をこのクラスのメソッドとして使えるようにする
  # Controllerが肥大化しないようにconcernsでモジュール化している
  # production環境以外ではRailsのエラーダンプが表示されるようにしておく
  include ErrorHandlers if Rails.env.production?

  private def set_layout
    if params[:controller].match(%r{\A(staff|admin|customer)/})
      Regexp.last_match[1]
    else
      "customer"
    end
  end
end

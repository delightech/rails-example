class Admin::Base < ApplicationController
  private def current_administrator
    # cookieにadministrator_idが保持されていた場合、DBからデータを引く
    if session[:administrator_id]
      @current_administrator ||= Administrator.find_by(id: session[:administrator_id])
    end
  end

  helper_method :current_administrator
end

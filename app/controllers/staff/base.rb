class Staff::Base < ApplicationController
  private def current_staff_member
    if session[:staff_member_id]
      @current_staff_member ||= StaffMember.find_by(id: session[:staff_member_id])
      pp @current_staff_member
      @current_staff_member
    end
  end

  helper_method :current_staff_member
end

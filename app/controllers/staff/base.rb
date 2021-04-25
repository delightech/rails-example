class Staff::Base < ApplicationController
  private def test
    if session[:staff_member_id]
      @current_staff_member ||= StaffMember.find_by(id: session[:staff_member_id])
    end
  end
  private def current_staff_member
    puts "current_staff_member###################"
    pp test
    puts "###################"
    test
  end

  helper_method :current_staff_member
end

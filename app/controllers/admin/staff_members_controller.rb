class Admin::StaffMembersController < Admin::Base
  def index
    # kanaでソートして全件取得している
    # View側で@staff_membersにeachメソッドが呼び出されるまではDB検索はされない
    @staff_members = StaffMember.order(:family_name_kana, :given_name_kana)
  end
end

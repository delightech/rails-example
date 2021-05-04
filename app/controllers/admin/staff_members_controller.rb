class Admin::StaffMembersController < Admin::Base
  def index
    # kanaでソートして全件取得している
    # View側で@staff_membersにeachメソッドが呼び出されるまではDB検索はされない
    @staff_members = StaffMember.order(:family_name_kana, :given_name_kana)
  end

  def show
    # findメソッドは、モデルオブジェクトのid属性の値（レコードの主キー値）を使ってレコードを検索する
    staff_member = StaffMember.find(params[:id])
    # 以下の場合、ルーティング名はedit_admin_staff_memberであると推定される
    # 式edit_admin_staff_member_path(id: staff_member.id)を評価した結果がリダイレクト先のURLパスとなる
    redirect_to [:edit, :admin, staff_member]
  end

  def new
    @staff_member = StaffMember.new
  end
end

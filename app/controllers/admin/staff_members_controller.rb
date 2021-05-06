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

  def edit
    @staff_member = StaffMember.find(params[:id])
  end

  def create
    # params[:staff_member]にはViewから入力された値がhashで送られてくる
    @staff_member = StaffMember.new(staff_member_params)
    if @staff_member.save
      flash.notice = "職員アカウントを新規登録しました。"
      # 登録成功時はindexアクションへリダイレクトする
      redirect_to :admin_staff_members
    else
      # 登録失敗時は新規登録Viewを表示
      render action: "new"
    end
  end

  def update
    @staff_member = StaffMember.find(params[:id])
    @staff_member.assign_attributes(staff_member_params)

    # assign_attributesは以下のようにも書ける。
    # @staff_member.attributes = params[:staff_member]
    # attributes=メソッドはassign_attributesのエイリアス

    # assign_attributesメソッドはリクエストされたデータをまとめてStaffMemberに適用するので、画面上入力欄を表示していないパスワード等も、ハックしてパラメータ送信すれば更新できてしまう。これをマスアサインメント脆弱性という。

    if @staff_member.save
      flash.notice = "職員アカウントを更新しました。"
      redirect_to :admin_staff_members
    else
      render action: "edit"
    end
  end

  private def staff_member_params
    params.require(:staff_member).permit(
      :email, :password, :family_name, :given_name,
      :family_name_kana, :given_name_kana,
      :start_date, :end_date, :suspended
    )
  end

  def destroy
    staff_member = StaffMember.find(params[:id])
    staff_member.destroy!
    flash.notice = "職員アカウントを削除しました。"
    redirect_to :admin_staff_members
  end
end

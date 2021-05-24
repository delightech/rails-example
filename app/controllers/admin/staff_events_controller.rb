class Admin::StaffEventsController < Admin::Base
  def index
    # staff_member_idが送信されてくるかどうかでネストされたリソースを表示するかどうか判断する
    if params[:staff_member_id]
      @staff_member = StaffMember.find(params[:staff_member_id])
      # created_at（occured_at）で降順ソート
      @events = @staff_member.events.order(occurred_at: :desc)
    else
      # created_at（occured_at）で降順ソート
      @events = StaffEvent.order(occurred_at: :desc)
    end
    # 関連付けられたモデルオブジェクトを一括取得する
    # 以下で、StaffMemberを一つずつID指定してクエリ発行するのではなく、in指定で一括取得できる
    # これによりSQLを無駄に繰り返し発行するのを防げる
    @events = @events.includes(:member)
    # kaminari gemが提供するpageメソッドを使う
    # pageにnilを指定した場合は１になる
    @events = @events.page(params[:page])
    # 上記でDBアクセスが発生するのは、Viewで実際に使うタイミング
  end
end

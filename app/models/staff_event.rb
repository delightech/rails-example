class StaffEvent < ApplicationRecord
  self.inheritance_column = nil

  # 以下で、memberメソッドでStaffMemerを参照できるようになる
  belongs_to :member, class_name: "StaffMember", foreign_key: "staff_member_id"
  # created_atのエイリアスを設定
  alias_attribute :occurred_at, :created_at

  DESCRIPTIONS = {
    logged_in: "ログイン",
    logged_out: "ログアウト",
    rejected: "ログイン拒否"
  }

  def description
    # typeフィールドの値(文字列の固定値)をto_symでシンボルに変換している
    DESCRIPTIONS[type.to_sym]
  end
end
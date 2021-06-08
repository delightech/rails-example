class Administrator < ApplicationRecord
  include EmailHolder
  include PasswordHolder

  # StaffMember同様の設計
  # 後でアカウント状態に影響するパラメーがを追加できるようにメソッドでラップしておく
  def active?
    !suspended?
  end
end

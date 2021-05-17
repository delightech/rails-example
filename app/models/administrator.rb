class Administrator < ApplicationRecord
  def password=(raw_password)
    if raw_password.kind_of?(String)
      self.hashed_password = BCrypt::Password.create(raw_password)
    elsif raw_password.nil?
      self.hashed_password = nil
    end
  end

  # StaffMember同様の設計
  # 後でアカウント状態に影響するパラメーがを追加できるようにメソッドでラップしておく
  def active?
    !suspended?
  end
end

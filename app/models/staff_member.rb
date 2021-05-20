class StaffMember < ApplicationRecord
  # ここで指定するシンボル「:events」と同名のインスタンスメソッドが定義される
  # 既存のインスタンスメソッド名とかぶらないように設定する必要がある
  # has_many :staff_events とするとRails側でクラス名が推定可能なので class_nameオプションを省略可能
  # dependent: :destroyで、StaffMember削除実行時、StaffMemberを削除する前に関連するStaffEventを全て削除する
  has_many :events, class_name: "StaffEvent", dependent: :destroy

  def password=(raw_password)
    if raw_password.kind_of?(String)
      self.hashed_password = BCrypt::Password.create(raw_password)
    elsif raw_password.nil?
      self.hashed_password = nil
    end
  end

  def active?
    !suspended? && start_date <= Date.today &&
      (end_date.nil? || end_date > Date.today)
  end
end

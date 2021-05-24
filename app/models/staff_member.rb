class StaffMember < ApplicationRecord
  # ここで指定するシンボル「:events」と同名のインスタンスメソッドが定義される
  # 既存のインスタンスメソッド名とかぶらないように設定する必要がある
  # has_many :staff_events とするとRails側でクラス名が推定可能なので class_nameオプションを省略可能
  # dependent: :destroyで、StaffMember削除実行時、StaffMemberを削除する前に関連するStaffEventを全て削除する
  has_many :events, class_name: "StaffEvent", dependent: :destroy

  # \p{katakana} は任意のカタカナ一文字にマッチする
  # \u{30fc} は長音符「-」1文字にマッチする
  KATAKANA_REGEXP = /\A[\p{katakana}\u{30fc}]+\z/

  # presence: trueで値が空の場合に失敗する（半角スペース、タブ文字も失敗する）
  validates :family_name, :given_name, presence: true
  # allow_blank: tureは値が空の場合はバリデーションスキップ
  validates :family_name_kana, :given_name_kana, presence: true, format: { with: KATAKANA_REGEXP, allow_blank: true }

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

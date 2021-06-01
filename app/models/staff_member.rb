class StaffMember < ApplicationRecord
  include StringNormalizer
  # before_validation, vadatesを以下でも定義
  # 名前系のバリデーションmodule
  include PersonalNameHolder

  # ここで指定するシンボル「:events」と同名のインスタンスメソッドが定義される
  # 既存のインスタンスメソッド名とかぶらないように設定する必要がある
  # has_many :staff_events とするとRails側でクラス名が推定可能なので class_nameオプションを省略可能
  # dependent: :destroyで、StaffMember削除実行時、StaffMemberを削除する前に関連するStaffEventを全て削除する
  has_many :events, class_name: "StaffEvent", dependent: :destroy

  # ActiveRecord::Baseのクラスメソッド
  # ブロックに指定した処理がバリデーションの直前にコールバックされる
  before_validation do
    self.email = normalize_as_email(email)
  end

  # uniqueness {case_sensitive: false}とすることで、大文字小文字を区別しないでユニークチェックをする
  validates :email, presence: true, "valid_email_2/email": true, uniqueness: { case_sensitive: false }
  validates :start_date, presence: true, date: {
    # 2000/1/1以降指定（2020/1/1を含む）
    after_or_equal_to: Date.new(2000, 1, 1),
    # 今日から1年後の日付より前(指定した日付を含まない)
    # ->(obj) はProcオブジェクト。objはProcの引数でStaffMemberオブジェクト自体が入る
    #   beforeの値は動的に決まるのでProcオブジェクトにしている
    #   Procオブジェクトにしない場合、productionモード時はクラス読み込みが起動時に一度だけなので、日付が固定化されてしまう
    before: ->(obj) { 1.year.from_now.to_date },
    # 空欄を許可
    allow_blank: true
  }
  validates :end_date, date: {
    # :start_dateよりあと
    after: :start_date,
    # 今日から1年後の日付より前
    # ->(obj) はProcオブジェクト。objはProcの引数でStaffMemberオブジェクト自体が入る
    before: ->(obj) { 1.year.from_now.to_date },
    # 空欄を許可
    allow_blank: true
  }

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

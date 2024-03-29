class StaffMember < ApplicationRecord
  # before_validation, vadatesを以下module内でも定義
  include EmailHolder
  include PersonalNameHolder
  include PasswordHolder

  # ここで指定するシンボル「:events」と同名のインスタンスメソッドが定義される
  # 既存のインスタンスメソッド名とかぶらないように設定する必要がある
  # has_many :staff_events とするとRails側でクラス名が推定可能なので class_nameオプションを省略可能
  # dependent: :destroyで、StaffMember削除実行時、StaffMemberを削除する前に関連するStaffEventを全て削除する
  has_many :events, class_name: "StaffEvent", dependent: :destroy

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

  def active?
    !suspended? && start_date <= Date.today &&
      (end_date.nil? || end_date > Date.today)
  end
end

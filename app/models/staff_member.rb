class StaffMember < ApplicationRecord
  include StringNormalizer
  # ここで指定するシンボル「:events」と同名のインスタンスメソッドが定義される
  # 既存のインスタンスメソッド名とかぶらないように設定する必要がある
  # has_many :staff_events とするとRails側でクラス名が推定可能なので class_nameオプションを省略可能
  # dependent: :destroyで、StaffMember削除実行時、StaffMemberを削除する前に関連するStaffEventを全て削除する
  has_many :events, class_name: "StaffEvent", dependent: :destroy

  # ActiveRecord::Baseのクラスメソッド
  # ブロックに指定した処理がバリデーションの直前にコールバックされる
  before_validation do
    self.email = normalize_as_email(email)
    self.family_name = normalize_as_name(family_name)
    self.given_name = normalize_as_name(given_name)
    self.family_name_kana = normalize_as_furigana(family_name_kana)
    self.given_name_kana = normalize_as_furigana(given_name_kana)
  end

  # 漢字、平仮名、カタカナ、長音符、アルファベットのみにマッチする
  HUMAN_NAME_REGEXP = /\A[\p{han}\p{hiragana}\p{katakana}\u{30fc}A-Za-z]+\z/

  # \p{katakana} は任意のカタカナ一文字にマッチする
  # \u{30fc} は長音符「-」1文字にマッチする
  KATAKANA_REGEXP = /\A[\p{katakana}\u{30fc}]+\z/

  # uniqueness {case_sensitive: false}とすることで、大文字小文字を区別しないでユニークチェックをする
  validates :email, presence: true, "valid_email_2/email": true, uniqueness: { case_sensitive: false }
  # presence: trueで値が空の場合にバリデーションエラー（半角スペース、タブ文字も失敗する）
  validates :family_name, :given_name, presence: true, format: { with: HUMAN_NAME_REGEXP, allow_blank: true}
  # formatは正規表現にマッチするかのバリデーション。allow_blankオプションは、値が空の場合はバリデーションスキップ
  validates :family_name_kana, :given_name_kana, presence: true, format: { with: KATAKANA_REGEXP, allow_blank: true }
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

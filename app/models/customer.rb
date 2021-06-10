class Customer < ApplicationRecord
  include EmailHolder
  include PersonalNameHolder
  include PasswordHolder

  # has_one はモデル間に1対1の関連付けを設定する
  # dependent: :destroy としているので、Customerオブジェクトが削除される直前に、関連付けられたHomeAddressオブジェクトとWorkAddressオブジェクトが削除される
  has_one :home_address, dependent: :destroy, autosave: true
  has_one :work_address, dependent: :destroy, autosave: true
  # has_manyは 1対多 を表す
  # 顧客が持っている全ての電話番号のリストを返す
  has_many :phones, dependent: :destroy
  # Phoneモデルに関連付けしたpersonal_phonesという名前での関連付けをしている
  # ->でProcオブジェクトを作り、has_manyの第二引数に条件（scope）を指定
  # addres_idカラムがNULL(個人電番号)のレコードだけを取得する
  # autosaveをつけないのは、Address側で付与し行われるため
  # 顧客の個人電話番号だけを返す
  has_many :personal_phones,
    -> { where(address_id: nil).order(:id) },
    class_name: "Phone", autosave: true

  validates :gender, inclusion: { in: %w(male female), allow_blank: true }
  validates :birthday, date: {
    after_or_equal_to: Date.new(1990, 1, 1),
    before: ->(obj) { Date.today },
    allow_blank: true
  }
end

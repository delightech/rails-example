class Phone < ApplicationRecord
  include StringNormalizer

  belongs_to :customer, optional: true
  belongs_to :address, optional: true

  before_validation do
    self.number = normalize_as_phone_number(number)
    # numberから数字以外の文字(\D)を除去
    self.number_for_index = number.gsub(/\D/, "") if number
  end

  # DBに初めて登録される前に実行される処理
  before_create do
    # Addressオブジェクトと関連付けられている場合、Customerオブジェクトとの関連付けを行う
    self.customer = address.customer if address
  end

  # 電話番号のフォーマットチェック
  # 先頭に+が0個か1個、1つ以上の数字、ハイフンと数字が0個以上
  # \zは末尾を示す。$との違いは、\zは文字列中の途中の改行を無視するが、$は文字列途中でも改行を末尾としてマッチする
  validates :number, presence: true, format: { with: /\A\+?\d+(-\d+)*\z/, allow_blank: true }
end

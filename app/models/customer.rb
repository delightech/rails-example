class Customer < ApplicationRecord
  include PersonalNameHolder

  # has_one はモデル間に1対1の関連付けを設定する
  # dependent: :destroy としているので、Customerオブジェクトが削除される直前に、関連付けられたHomeAddressオブジェクトとWorkAddressオブジェクトが削除される
  has_one :home_address, dependent: :destroy, autosave: true
  has_one :work_address, dependent: :destroy, autosave: true

  validates :gender, inclusion: { in: %w(male female), allow_blank: true }
  validates :birthday, date: {
    after_or_equal_to: Date.new(1990, 1, 1),
    before: ->(obj) { Date.today },
    allow_blank: true
  }
  def password=(raw_password)
    if raw_password.kind_of?(String)
      self.hashed_password = BCrypt::Password.create(raw_password)
    elsif raw_password.nil?
      self.hashed_password = nil
    end
  end
end

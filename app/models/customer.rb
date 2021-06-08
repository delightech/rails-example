class Customer < ApplicationRecord
  include EmailHolder
  include PersonalNameHolder
  include PasswordHolder

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
end

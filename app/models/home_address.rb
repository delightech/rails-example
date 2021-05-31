class HomeAddress < Address
  validates :postal_code, :prefecture, :city, :address1, presence: true
  # absenceタイプのバリデーションは、指定された属性が空であることを確かめる
  validates :company_name, :division_name, absence: true
end
class Staff::ChangePasswordForm
  include ActiveModel::Model

  attr_accessor :object, :current_password, :new_password, :new_password_confirmation
  # confirmationタイプのバリデーションは、属性名 new_passwordに「_confirmation」を不可した名前を持つ属性とnew_password属性を比較し、一致しなければエラーとする
  validates :new_password, presence: true, confirmation: true

  # validateは組み込みバリデーション以外の方式でバリデーションを実装する時に使う
  validate do
    # services/staff/authenticator.rb のチェックを行う
    # objectはStaffMember
    unless Staff::Authenticator.new(object).authenticate(current_password)
      errors.add(:current_password, :wrong)
    end
  end

  def save
    if valid?
      object.password = new_password
      object.save!
    end
  end
end
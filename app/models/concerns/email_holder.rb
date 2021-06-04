module EmailHolder
  extend ActiveSupport::Concern

  included do
    include StringNormalizer

    before_validation do
      self.email = normalize_as_email(email)
    end

    # uniqueness {case_sensitive: false}とすることで、大文字小文字を区別しないでユニークチェックをする
    validates :email, presence: true, "valid_email_2/email": true, uniqueness: { case_sensitive: false }
  end
end
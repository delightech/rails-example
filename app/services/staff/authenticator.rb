class Staff::Authenticator
  def initialize(staff_member)
    @staff_member = staff_member
  end

  def authenticate(raw_password)
    @staff_member &&
      @staff_member.hashed_password &&
      @staff_member.start_date <= Date.today &&
      (@staff_member.end_date.nil? || @staff_member.end_date > Date.today) &&
      # この「==」は比較演算子ではなく、BCrypt::Passwordのインスタンスメソッド
      # 引数に指定した平文のパスワードをハッシュ化し、インスタンスが保持しているハッシュ値と同じであればtrueを返す
      BCrypt::Password.new(@staff_member.hashed_password) == raw_password
  end
end

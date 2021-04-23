require 'rails_helper'

RSpec.describe Administrator, type: :model do
  describe "#password=" do
    example "文字列を与えると、hashed_passwordは長さ60の文字列になる" do
      administrator = Administrator.new
      administrator.password = "test"
      expect(administrator.hashed_password).to be_kind_of(String)
      expect(administrator.hashed_password.size).to eq(60)
    end
    example "nilを与えると、hashed_passwordはnilになる" do
      administrator = Administrator.new(hashed_password: "test")
      administrator.password = nil
      expect(administrator.hashed_password).to be_nil
    end
  end
end

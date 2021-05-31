FactoryBot.define do
  factory :customer do
    sequence(:email) { |n| "member#{n}@example.jp"}
    family_name { "山田" }
    given_name { "太郎" }
    family_name_kana { "ヤマダ" }
    given_name_kana { "タロウ" }
    password { "pw" }
    birthday { Date.new(1970, 1, 1) }
    gender { "male" }
    # associationメソッドで関連付けをする
    # 第一引数はファクトリー名、strategyオプションはbuildを指定している
    # これによりcustomer作成時にhome_addressとwork_addressがbuildで作成される
    association :home_address, strategy: :build
    association :work_address, strategy: :build
  end
end
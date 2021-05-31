require "rails_helper"

# featureメソッドはdescribeと同機能だが、Capybaraを使う際はfeatureを使う
feature "職員による顧客管理" do
  include FeaturesSpecHelper
  let(:staff_member) { create(:staff_member) }
  # !付きのletメソッドは定義時点でメモ化（一度だけオブジェクトが作られる）される
  # !なしのletメソッドは初回呼び出し時にメモ化される
  # customerは、編集ページのテストの際に編集リンクが押下されたタイミングで存在していなければならない。なので!を付けて、この時点でDBにデータを入れておく必要がある
  let!(:customer) { create(:customer) }

  before do
    switch_namespace(:staff)
    # staff_memberはこの時点で生成されメモ化される
    login_as_staff_member(staff_member)
  end

  # scenarioメソッドはCapybaraが提供するexampleのalias。Capybaraを使う際は明示的にscenarioを使う
  scenario "職員が顧客、自宅住所、勤務先を更新する" do
    # 以下、空行でセクションを分けている。これはRailsコミュニティの慣習

    # 1. Givenセクション
    # Givenセクションではシナリオの前提条件を記述
    click_link "顧客管理"
    # firstメソッドは引数のCSSセレクタの最初の要素を取得する
    # click_linkはa要素のリンク文字列かid属性の値を指定する
    # ※実際には、このページには1つしか編集リンクがないので下記のようにも書ける。ここでは説明のためにfirstを使っている
    # click_link "編集"
    first("table.listing").click_link "編集"

    # 1. Whenセクション
    # Whenセクションはシナリオの本体。ユーザーがブラウザ上でどんな操作をするかを記述
    fill_in "メールアドレス", with: "test@example.jp"
    within("fieldset#home-address-fields") do
      fill_in "郵便番号", with: "9999999"
    end
    within("fieldset#work-address-fields") do
      fill_in "会社名", with: "テスト"
    end
    click_button "更新"

    # 1. Thenセクション
    # Thenセクションはシナリオの結果を確かめるコードを記述
    # reloadでCustomerオブジェクトの各属性の値をDBから取得し直している
    customer.reload
    expect(customer.email).to eq("test@example.jp")
    expect(customer.home_address.postal_code).to eq("9999999")
    expect(customer.work_address.company_name).to eq("テスト")
  end
end
class Staff::CustomerForm
  include ActiveModel::Model

  attr_accessor :customer, :inputs_home_address, :inputs_work_address
  # persisted?はActiveModelではデフォルトfalseを返す。
  # delegateでcustomerに委譲すると、ActiveRecordのpersisted?が呼ばれる
  # ActiveRecordのpersisted?は、モデルオブジェクトがDBに保存されているならtrueを返す（new_record?の逆）
  # form_withはpersisted?を評価して、trueならPATCH（更新）、falseならPOST（登録）でHTTPメソッドを判定している。
  # この委譲を行わない場合、persisted?はfalseとなり、HTTPメソッドがPOSTで固定されてしまう。
  delegate :persisted?, :save, to: :customer

  def initialize(customer = nil)
    @customer = customer
    @customer ||= Customer.new(gender: "male")
    # 個人電話番号が２個未満の顧客に不足分のPhoneモデルを追加する
    (2 - @customer.personal_phones.size).times do
      @customer.personal_phones.build
    end
    # 顧客アカウントがHomeAddressオブジェクトを持っていれば該当するチェックボックスがONになるようにする
    self.inputs_home_address = @customer.home_address.present?
    # 顧客アカウントがWorkAddressオブジェクトを持っていれば該当するチェックボックスがONになるようにする
    self.inputs_work_address = @customer.work_address.present?
    # build_home_addressは Customer に has_one で追加されるインスタンスメソッド
    # HomeAddressオブジェクトをインスタンス化してCustomerと結びつける。
    # この時点ではHomeAddressオブジェクトはDBに保存されず、フォームを表示するために利用される
    @customer.build_home_address unless @customer.home_address
    @customer.build_work_address unless @customer.work_address
    (2 - @customer.home_address.phones.size).times do
      @customer.home_address.phones.build
    end
    (2 - @customer.work_address.phones.size).times do
      @customer.work_address.phones.build
    end
  end

  def assign_attributes(params = {})
    @params = params
    self.inputs_home_address = params[:inputs_home_address] == "1"
    self.inputs_work_address = params[:inputs_work_address] == "1"

    # attr_accessor :customer で@customerをcustomerで呼び出せる。意味は同じ

    # params[:form][:customer]の送信された各フィールドの値を入れる
    customer.assign_attributes(customer_params)
    # phone_params(:customer) の戻り値はActionController::Parametersオブジェクト
    # fetchはActionController::Parametersオブジェクトの内、引数に指定したキーのオブジェクトを返す
    phones = phone_params(:customer).fetch(:phones)

    customer.personal_phones.size.times do |index|
      attributes = phones[index.to_s]
      if attributes && attributes[:number].present?
        customer.personal_phones[index].assign_attributes(attributes)
      else
        # numberがない場合、mark_for_destructionで削除対象のマークを付ける
        customer.personal_phones[index].mark_for_destruction
      end
    end

    if inputs_home_address
      # params[:form][:customer][:home_address]の送信された各フィールドの値を入れる
      customer.home_address.assign_attributes(home_address_params)
      phones = phone_params(:home_address).fetch(:phones)
      customer.home_address.phones.size.times do |index|
        attributes = phones[index.to_s]
        if attributes && attributes[:number].present?
          customer.home_address.phones[index].assign_attributes(attributes)
        else
          customer.home_address.phones[index].mark_for_destruction
        end
      end
    else
      # 関連付けられたモデルオブジェクト（ここではHomeAddress）のmark_for_destructionメソッドを呼び出すと、親（ここではCustomer）が保存される際に、関連オブジェクトが自動的にDBから削除される
      # 未保存のデータ（新規登録など）の場合は、バリデーションと保存の処理がスキップされる
      # この仕組みを機能させるためには、クラスメソッドの has_one のautosaveオプションにtrueが指定されている必要がある
      customer.home_address.mark_for_destruction
    end
    if inputs_work_address
      # params[:form][:customer][:work_address]の送信された各フィールドの値を入れる
      customer.work_address.assign_attributes(work_address_params)
      phones = phone_params(:work_address).fetch(:phones)

      customer.work_address.phones.size.times do |index|
        attributes = phones[index.to_s]
        if attributes && attributes[:number].present?
          customer.work_address.phones[index].assign_attributes(attributes)
        else
          customer.work_address.phones[index].mark_for_destruction
        end
      end
    else
      # 関連付けられたモデルオブジェクト（ここではWorkAddress）のmark_for_destructionメソッドを呼び出すと、親（ここではCustomer）が保存される際に、関連オブジェクトが自動的にDBから削除される
      # 未保存のデータ（新規登録など）の場合は、バリデーションと保存の処理がスキップされる
      # この仕組みを機能させるためには、クラスメソッドの has_one のautosaveオプションにtrueが指定されている必要がある
      customer.work_address.mark_for_destruction
    end
  end

  # saveメソッドをmodel側でautosave: trueにしておくと関連オブジェクト含めバリデーションチェック後にtransactionで保存される
  # saveメソッドは、customerに委譲しておくことで、customer_form.saveでcustomer.saveを呼び出せる。こうすることでコードを短くできる
  #def save
  #  customer.save
  #end

  # saveメソッドを個別に書くと以下のようになる
  #def save
  #  # !付きのsaveは、保存前のバリデーションで失敗するとActiveRecord::RecordInvalidエラーを発生させるのでバリデーションが通ったかどうかをチェックしてからsave!する
  #  if valid?
  #    ActiveRecord::Base.transaction do
  #      customer.save!
  #      # HomeAddressとWorkAddressは、Customerとは別に、明示的に保存する必要がある
  #      customer.home_address.save!
  #      customer.work_address.save!
  #    end
  #  end
  #end

  #def valid?
  #  # mapで配列内のオブジェクトのvalid?を実行し、その結果の真偽値の配列を返す
  #  # [...].map(&:valid?) の引数は、引数を一つ取るブロックに変換される。引数「&シンボル」は、メソッドとしてすべての要素で実行される
  #  # 例）[...].map(&:name) → [...].map { |e| e.name }
  #  # all?は配列の全要素が真である場合に真を返す
  #  [customer, customer.home_address, customer.work_address].map(&:valid?).all?
  #  # 下記のように実装すると、最初のcustomer.valid?がfalseの場合、以降のvalid?が評価されず、エラー値が入力されていても画面にエラーが表示されない状態になるため
  #  # if customer.valid? && customer.home_address.valid? && customer.work_address.valid?
  #end

  private def customer_params
    @params.require(:customer).except(:phones).permit(
      :email, :password,
      :family_name, :given_name, :family_name_kana, :given_name_kana,
      :birthday, :gender
    )
  end

  private def home_address_params
    @params.require(:home_address).except(:phones).permit(
      :postal_code, :prefecture, :city, :address1, :address2,
    )
  end

  private def work_address_params
    @params.require(:work_address).except(:phones).permit(
      :postal_code, :prefecture, :city, :address1, :address2,
      :company_name, :division_name
    )
  end

  private def phone_params(record_name)
    #pp record_name
    #=> :customer
    #pp @params.require(record_name)
    #=> #<ActionController::Parameters {"email"=>"ito.ichiro@example.jp", "family_name"=>"伊藤", "given_name"=>"一郎", "family_name_kana"=>"イトウ", "given_name_kana"=>"イチロウ", "birthday"=>"2015-06-08", "gender"=>"male", "phones"=>{"0"=>{"number"=>"090-0000-0050", "primary"=>"0"}, "1"=>{"number"=>"", "primary"=>"0"}}} permitted: false>
    #pp @params.require(record_name).slice(:phones)
    #=> #<ActionController::Parameters {"phones"=>{"0"=>{"number"=>"090-0000-0050", "primary"=>"0"}, "1"=>{"number"=>"", "primary"=>"0"}}} permitted: false>

    # phoneオブジェクトのみ取り出してチェックする
    # ここでのpermitは下記をチェックする
    # {"0"=>{"number"=>"090-1234-5678","primary"=>"1"}, "1"=>{"number"=>"","primary"=>"0"}}
    # 上記数字のキーをもつハッシュを下記のような配列とみなしチェックする
    # [{"number"=>"090-1234-5678","primary"=>"1"}, {"number"=>"","primary"=>"0"}]
    # 配列ように扱い許可をするのは以下の部分
    # permit(phones: [:number, :primary])
    @params.require(record_name)
      .slice(:phones).permit(phones: [:number, :primary])
  end
end
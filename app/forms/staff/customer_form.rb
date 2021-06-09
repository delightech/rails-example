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
    # 顧客アカウントがHomeAddressオブジェクトを持っていれば該当するチェックボックスがONになるようにする
    self.inputs_home_address = @customer.home_address.present?
    # 顧客アカウントがWorkAddressオブジェクトを持っていれば該当するチェックボックスがONになるようにする
    self.inputs_work_address = @customer.work_address.present?
    # build_home_addressは Customer に has_one で追加されるインスタンスメソッド
    # HomeAddressオブジェクトをインスタンス化してCustomerと結びつける。
    # この時点ではHomeAddressオブジェクトはDBに保存されず、フォームを表示するために利用される
    @customer.build_home_address unless @customer.home_address
    @customer.build_work_address unless @customer.work_address
  end

  def assign_attributes(params = {})
    @params = params

    # attr_accessor :customer で@customerをcustomerで呼び出せる。意味は同じ

    # params[:form][:customer]の送信された各フィールドの値を入れる
    customer.assign_attributes(customer_params)
    # params[:form][:customer][:home_address]の送信された各フィールドの値を入れる
    customer.home_address.assign_attributes(home_address_params)
    # params[:form][:customer][:work_address]の送信された各フィールドの値を入れる
    customer.work_address.assign_attributes(work_address_params)
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
    @params.require(:customer).permit(
      :email, :password,
      :family_name, :given_name, :family_name_kana, :given_name_kana,
      :birthday, :gender
    )
  end

  private def home_address_params
    @params.require(:home_address).permit(
      :postal_code, :prefecture, :city, :address1, :address2,
    )
  end

  private def work_address_params
    @params.require(:work_address).permit(
      :postal_code, :prefecture, :city, :address1, :address2,
      :company_name, :division_name
    )
  end
end
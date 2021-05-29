class Staff::CustomerForm
  include ActiveModel::Model

  attr_accessor :customer
  # persisted?はActiveModelではデフォルトfalseを返す。
  # delegateでcustomerに委譲すると、ActiveRecordのpersisted?が呼ばれる
  # ActiveRecordのpersisted?は、モデルオブジェクトがDBに保存されているならtrueを返す（new_record?の逆）
  # form_withはpersisted?を評価して、trueならPATCH（更新）、falseならPOST（登録）でHTTPメソッドを判定している。
  # この委譲を行わない場合、persisted?はfalseとなり、HTTPメソッドがPOSTで固定されてしまう。
  delegate :persisted?, to: :customer

  def def initialize(customer = nil)
    @customer = customer
    @customer ||= Customer.new(gender: "male")
    # build_home_addressは Customer に has_one で追加されるインスタンスメソッド
    # HomeAddressオブジェクトをインスタンス化してCustomerと結びつける。
    # この時点ではHomeAddressオブジェクトはDBに保存されず、フォームを表示するために利用される
    @customer.build_home_address unless @customer.home_address
    @customer.build_home_address unless @customer.work_address
  end
  end
end
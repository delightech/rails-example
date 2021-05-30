class Staff::CustomerForm
  include ActiveModel::Model

  attr_accessor :customer
  # persisted?はActiveModelではデフォルトfalseを返す。
  # delegateでcustomerに委譲すると、ActiveRecordのpersisted?が呼ばれる
  # ActiveRecordのpersisted?は、モデルオブジェクトがDBに保存されているならtrueを返す（new_record?の逆）
  # form_withはpersisted?を評価して、trueならPATCH（更新）、falseならPOST（登録）でHTTPメソッドを判定している。
  # この委譲を行わない場合、persisted?はfalseとなり、HTTPメソッドがPOSTで固定されてしまう。
  delegate :persisted?, to: :customer

  def initialize(customer = nil)
    @customer = customer
    @customer ||= Customer.new(gender: "male")
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

  def save
    ActiveRecord::Base.transaction do
      customer.save!
      # HomeAddressとWorkAddressは、Customerとは別に、明示的に保存する必要がある
      customer.home_address.save!
      customer.work_address.save!
    end
  end

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
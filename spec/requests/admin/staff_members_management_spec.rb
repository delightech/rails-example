require 'rails_helper'

# describeの第二引数はcontext。どのような文脈でdescribeが実行されるかを示す。
# 下記のようにcontextブロックを内側に書くのと同様。
# describe "管理者による職員管理" do
#   context "ログイン前" do
#     include_examples "a protected admin controller", "admin/staff_members"
#   end
# end
describe "管理者による職員管理", "ログイン前" do
  # include_examplesでshared_examplesを読み込む（shared_examples内のコードがここにそのまま記述されるのと同等になる）
  # 第一引数は、includeするshared_examplesの名前を指定
  # 第二引数は、shared_examplesのブロック引数になる
  include_examples "a protected admin controller", "admin/staff_members"
end

describe "管理者による職員管理" do
  # letはメモ化を行う。メモ化とは以下。
  #  初回のみメソッド実行して結果を保持し、それを返します。
  #  2回目以降はメソッド実行せず、保持したものを返します。
  let(:administrator) { create(:administrator) }

  before do
    post admin_session_url,
      params: {
        admin_login_form: {
          email: administrator.email,
          password: "pw"
        }
      }

  end

  describe "新規登録" do
    # attributes_forはFactoryBotがassign_attributes可能なhashを返す
    # ここではFactoryBot.defineで定義した:staff_memberのhashを返す
    # letで定義した変数はexample内でのみ参照可能。describe, contextでは使えないので注意
    let(:params_hash) { attributes_for(:staff_member) }

    example "職員一覧ページにリダイレクト" do
      # postはコントローラのspec特有のメソッド。第一引数に指定されたメソッドに対して、
      # 第二引数に指定されたデータをPOSTで送信する。実際にはRSpec内部で疑似HTTPリクエストが行われ、
      # 実際にアクションが実行されて結果を調べることができる。
      post admin_staff_members_url, params: { staff_member: params_hash }
      # responseはActionC::TestResponseオブジェクトを返すメソッド。アクションの実行結果を保持している。
      # redirect_toは引数に指定したURLパスへのリダイレクトがアクションの中で発生したかを調べるマッチャー。
      # admin_staff_members_urlはconfig/routes.rbで定義されたヘルパーメソッド。
      expect(response).to redirect_to(admin_staff_members_url)
    end

    example "例外ActionController::ParameterMissingが発生" do
      expect { post admin_staff_members_url }.to raise_error(ActionController::ParameterMissing)
    end
  end

  describe "更新" do
    # createもFactoryBotのメソッド。定義済みの:staff_memberファクトリーを用い、StaffMemberオブジェクトを作ってDBに保存し、そのオブジェクトを返す。
    let(:staff_member) { create(:staff_member) }
    let(:params_hash) { attributes_for(:staff_member) }

    example "suspendedフラグをセットする" do
      # suspendedの値を入れ替える
      params_hash.merge!(suspended: true)
      patch admin_staff_member_url(staff_member), params: {staff_member: params_hash}
      # オブジェクトの各属性の値をDBから再取得する
      staff_member.reload
      # beマッチャー。以下の様に記述することで、staff_memberのsuspendメソッドに?を付けたメソッドが呼び出される
      expect(staff_member).to be_suspended
    end

    example "hashed_passwordの値は書き換え不可" do
      params_hash.delete(:password)
      params_hash.merge!(hashed_password: "x")
      # strong parameterのチェック
      # hashed_passwordを変えてpatch送信してもhashed_passwordが変わらないことを確認する
      expect{
        patch admin_staff_member_url(staff_member), params: {staff_member: params_hash}
      }.not_to change {staff_member.hashed_password.to_s}
    end
  end
end
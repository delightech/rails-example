class StaffEventPresenter < ModelPresenter
  # objectはStaffEventが渡ってくる
  # member, description, occurred_atメソッドはそれぞれ、委譲で以下のメソッドが呼び出されることになる
  # StaffEvent#member
  # StaffEvent#description
  # StaffEvent#occurred_at
  delegate :member, :description, :occurred_at, to: :object

  def table_row
    # 親クラスでHtmlBuilderをincludeしているのでHtmlBuilder#markupメソッドが使える
    markup(:tr) do |m|
      # instance_variable_getはレシーバが持っているインスタンス変数の値を取得するメソッド
      # views/admin/staff_events/_event.html.erb 部分テンプレートのインスタンス変数@staff_memberの値を取得している
      # staff_memberに値がないなら、全ての職員のeventリストを名前と一緒に表示している
      unless view_context.instance_variable_get(:@staff_member)
        # 例）<td><a href="/admin/staff_members/:id/staff_events">名前</a></td>
        m.td do
          # link_toで作成したタグ文字列を<<メソッドで追加する
          m << link_to(member.family_name + member.given_name, [:admin, member, :staff_events])
        end
      end

      m.td description

      # <td class="date">YYYY/mm/dd HH:MM:SS<td>
      m.td(:class => "date") do
        m.text occurred_at.strftime("%Y/%m/%d %H:%M:%S")
      end
    end
  end
end
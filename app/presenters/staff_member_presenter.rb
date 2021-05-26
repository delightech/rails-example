class StaffMemberPresenter < ModelPresenter
  # suspended?メソッドをStaffMemberPresenterオブジェクトに持たせ、objectオブジェクトに委譲する
  # StaffMemberPresenter#suspended?を呼ぶと、object#suspended?が呼ばれる
  delegate :suspended?, to: :object
  # 職員の停止フラグのOn/Offを表現する記号を返す
  # On: BALLOT BOX WITH CHECK（U+2611）
  # Off: BALLOT BOX（U+2610）
  def suspended_mark
    # objectはStaffMemberが入ってくる
    # view_contextはRailsで定義された全てのヘルパーメソッドを持つ。Viewで渡したselfオブジェクト
    # rawはViewで使えるrawメソッドと同じもの
    object.suspended? ? view_context.raw("&#x2611;") : view_context.raw("&#x2610;")
  end
end
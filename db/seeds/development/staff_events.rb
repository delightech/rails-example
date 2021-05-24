staff_members = StaffMember.all

256.times do |n|
  # sampleは配列からランダムに要素を抽出するメソッド
  m = staff_members.sample
  # buildは以下と同値。staff_memberに関連付けられたStaffEventオブジェクトを作成する
  # StaffEvent.new(member: m)
  # buildの時点ではDBに保存しない
  e = m.events.build
  if m.active?
    if n.even?
      e.type = "logged_in"
    else
      e.type = "logged_out"
    end
  else
    e.type = "rejected"
  end
  e.occurred_at = (256 - n).hours.ago
  e.save!
end
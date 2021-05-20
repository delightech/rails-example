class CreateStaffEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :staff_events do |t|
      # staff_memberテーブルへの外部キー
      # 指定した名前に「_id」を付与した整数型のカラム（ここではstaff_member_id）を定義する
      # これによりstaff_eventsとstaff_membersに一対多の関連付けがされる
      # ここではstaff_member_idにindexを指定せず、add_indexで複合indexとする
      t.references :staff_member, null: false, index: false, foreign_key: true
      t.string :type, null: false
      t.datetime :created_at, null: false
    end

    add_index :staff_events, :created_at
    # この複合indexで、職員別のイベントリストを時刻順にソートして取得したいときのパフォーマンスが向上する
    add_index :staff_events, [ :staff_member_id, :created_at ]
  end
end

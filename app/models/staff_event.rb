class StaffEvent < ApplicationRecord
  self.inheritance_column = nil

  # 以下で、memberメソッドでStaffMemerを参照できるようになる
  belongs_to :member, class_name: "StaffMember", foreign_key: "staff_member_id"
  alias_attribute :occured_at, :created_at
end
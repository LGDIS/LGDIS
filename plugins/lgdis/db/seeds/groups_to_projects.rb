# -*- coding: utf-8 -*-

# 全件削除
ActiveRecord::Base.connection.execute(%{DELETE FROM members})
ActiveRecord::Base.connection.execute(%{SELECT setval('members_id_seq', 1, FALSE)})
ActiveRecord::Base.connection.execute(%{DELETE FROM member_roles})
ActiveRecord::Base.connection.execute(%{SELECT setval('member_roles_id_seq', 1, FALSE)})

# 登録
CSV.foreach("#{Rails.root}/plugins/lgdis/db/seeds/groups_to_projects.csv", :headers => true) do |row|
  h = row.to_hash
  h.each_key do |k|
    h[k] = YAML.load(h[k])
  end
  membership_id = nil # 新規登録なのでnil
  params = {
    "project_id" => h["project_id"],
    "role_ids"   => h["role_ids"],
  }
  membership = Member.edit_membership(membership_id, params, Group.find(h["group_id"]))
  membership.save!
end

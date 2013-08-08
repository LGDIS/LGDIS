# -*- coding: utf-8 -*-

# 全件削除
ActiveRecord::Base.connection.execute(%{DELETE FROM users WHERE id > 2})
ActiveRecord::Base.connection.execute(%{SELECT setval('users_id_seq', 3, FALSE)})

# 登録
CSV.foreach("#{Rails.root}/plugins/lgdis/db/seeds/groups.csv", :headers => true) do |row|
  h = row.to_hash
  h.each_key do |k|
    h[k] = YAML.load(h[k])
  end
  group = Group.new
#  group.safe_attributes = h
  group.lastname = h["name"]
  group.save!
end

# -*- coding: utf-8 -*-

# 全件削除
ActiveRecord::Base.connection.execute(%{DELETE FROM roles})
ActiveRecord::Base.connection.execute(%{SELECT setval('roles_id_seq', 1, FALSE)})

# 登録
CSV.foreach("#{Rails.root}/plugins/lgdis/db/seeds/roles.csv", :headers => true) do |row|
  h = row.to_hash
  h.each_key do |k|
    h[k] = YAML.load(h[k])
  end
  r = Role.create!(h)
  r.builtin = h["builtin"]
  r.save(:validate => false)
end

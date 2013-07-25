# -*- coding: utf-8 -*-

# 全件削除
ActiveRecord::Base.connection.execute(%{DELETE FROM enabled_modules})
ActiveRecord::Base.connection.execute(%{SELECT setval('enabled_modules_id_seq', 1, FALSE)})
ActiveRecord::Base.connection.execute(%{DELETE FROM projects})
ActiveRecord::Base.connection.execute(%{DELETE FROM projects_trackers})
ActiveRecord::Base.connection.execute(%{SELECT setval('projects_id_seq', 1, FALSE)})
ActiveRecord::Base.connection.execute(%{SELECT setval('projects_identifier_seq', 1, FALSE)})

# 登録
CSV.foreach("#{Rails.root}/plugins/lgdis/db/seeds/projects.csv", :headers => true) do |row|
  h = row.to_hash
  h.each_key do |k|
    h[k] = YAML.load(h[k])
  end
  params = h.merge({
    :parent_id => ""
  })
  project = Project.new
  project.safe_attributes = params
  project.save!
end

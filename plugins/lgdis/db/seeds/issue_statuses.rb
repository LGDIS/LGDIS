# -*- coding: utf-8 -*-

# 全件削除
ActiveRecord::Base.connection.execute(%{DELETE FROM issue_statuses})
ActiveRecord::Base.connection.execute(%{SELECT setval('issue_statuses_id_seq', 1, FALSE)})

# 登録
CSV.foreach("#{Rails.root}/plugins/lgdis/db/seeds/issue_statuses.csv", :headers => true) do |row|
  IssueStatus.create!(row.to_hash)
end

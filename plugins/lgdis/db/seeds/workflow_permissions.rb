WorkflowPermission.delete_all
CSV.foreach("#{Rails.root}/plugins/lgdis/db/seeds/workflow_permissions.csv",:headers => true) do |row|
  WorkflowPermission.create!(row.to_hash)
end

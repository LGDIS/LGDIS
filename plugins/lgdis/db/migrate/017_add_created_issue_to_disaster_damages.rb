# encoding: utf-8
class AddCreatedIssueToDisasterDamages < ActiveRecord::Migration
  def change
    add_column :disaster_damages, :created_issue, :boolean

    set_column_comment(:disaster_damages, :created_issue, "チケット作成有無")
  end
end

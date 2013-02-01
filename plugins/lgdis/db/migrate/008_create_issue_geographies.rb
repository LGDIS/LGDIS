# -*- coding:utf-8 -*-
class CreateIssueGeographies < ActiveRecord::Migration
  def change
    create_table :issue_geographies do |t|
      t.column :id,       :integer
      t.column :issue_id, :integer
      t.column :datum,    :string
      t.column :location, :string
      t.column :point,    :point
      t.column :line,     :line
      t.column :polygon,  :polygon
      t.column :remarks,  :text
    end

    set_table_comment(:issue_geographies, "チケット追加地理データ")
    set_column_comment(:issue_geographies , :id,       "ID")
    set_column_comment(:issue_geographies , :issue_id, "チケット番号")
    set_column_comment(:issue_geographies , :datum,    "測地系")
    set_column_comment(:issue_geographies , :location, "場所")
    set_column_comment(:issue_geographies , :point,    "経緯度")
    set_column_comment(:issue_geographies , :line,     "線形")
    set_column_comment(:issue_geographies , :polygon,  "多角形")
    set_column_comment(:issue_geographies , :remarks,  "備考")
  end
end

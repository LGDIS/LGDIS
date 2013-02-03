# -*- coding:utf-8 -*-
class CreateIssueGeographies < ActiveRecord::Migration
  def change
    create_table :issue_geographies do |t|
      t.references :issue, :null => false
      t.string     :datum, :limit => 10
      t.string     :location, :limit => 100
      t.column     :point, :point
      t.column     :line, :path
      t.column     :polygon, :polygon
      t.string     :remarks, :limit => 255
      t.timestamps
    end

    set_table_comment(:issue_geographies, "チケット位置情報")
    set_column_comment(:issue_geographies, :datum,     "測地系")
    set_column_comment(:issue_geographies, :location,  "場所")
    set_column_comment(:issue_geographies, :point,     "経緯度")
    set_column_comment(:issue_geographies, :line,      "線")
    set_column_comment(:issue_geographies, :polygon,   "多角形")
    set_column_comment(:issue_geographies, :remarks,   "備考")
    set_column_comment(:issue_geographies, :created_at, "登録日時")
    set_column_comment(:issue_geographies, :updated_at, "更新日時")
  end
end

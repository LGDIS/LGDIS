# -*- coding:utf-8 -*-
class CreateGeographies < ActiveRecord::Migration
  def change
    create_table :geographies do |t|
      t.column :id,       :integer
      t.column :issue_id, :integer
      t.column :datum,    :string
      t.column :location, :string
      t.column :point,    :point
      t.column :line,     :line
      t.column :polygon,  :polygon
      t.column :remarks,  :text
    end

    set_table_comment(:geographies, "チケット追加地理データ")
    set_column_comment(:geographies , :id,       "ID")
    set_column_comment(:geographies , :issue_id, "チケット番号")
    set_column_comment(:geographies , :datum,    "測地系")
    set_column_comment(:geographies , :location, "場所")
    set_column_comment(:geographies , :point,    "経緯度")
    set_column_comment(:geographies , :line,     "線形")
    set_column_comment(:geographies , :polygon,  "多角形")
    set_column_comment(:geographies , :remarks,  "備考")
  end
end

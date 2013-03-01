# -*- coding:utf-8 -*-
class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.integer :id
      t.string  :area_code, :null => false, :default => "", :unique => true, :limit => 2
      t.string  :name, :limit => 30
      t.string  :remarks, :limit => 256
      t.column  :polygon, "decimal[]"

      t.timestamps
    end

    set_table_comment(:areas, "地区")
    set_column_comment(:areas, :id,         "ID")
    set_column_comment(:areas, :area_code,  "地区コード（大分類）")
    set_column_comment(:areas, :name,       "地区名称（大分類）")
    set_column_comment(:areas, :remarks,    "備考")
    set_column_comment(:areas, :polygon,    "ポリゴン")
    set_column_comment(:areas, :created_at, "作成時刻")
    set_column_comment(:areas, :updated_at, "更新時刻")
  end
end

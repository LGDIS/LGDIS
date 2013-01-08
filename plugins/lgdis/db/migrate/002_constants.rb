# encoding: utf-8
class Constants < ActiveRecord::Migration
  def change
    create_table :constants do |t|
      t.string  "kind1"
      t.string  "kind2"
      t.string  "kind3"
      t.string  "text"
      t.string  "value"
      t.integer "_order"
      t.timestamps
    end
    set_table_comment(:constants, "コンスタント")
    set_column_comment(:constants, :kind1,      "種別")
    set_column_comment(:constants, :kind2,      "テーブル名")
    set_column_comment(:constants, :kind3,      "カラム名")
    set_column_comment(:constants, :text,       "テキスト")
    set_column_comment(:constants, :value,      "値")
    set_column_comment(:constants, :_order,     "並び順")
    set_column_comment(:constants, :created_at, "登録日時")
    set_column_comment(:constants, :updated_at, "更新日時")
  end
end

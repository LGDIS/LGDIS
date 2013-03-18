# -*- coding:utf-8 -*-
class CreateEditionManagements < ActiveRecord::Migration
  def change
    create_table :edition_managements do |t|
      t.integer :project_id, :null => false
      t.integer :tracker_id, :null => false
      t.integer :issue_id,   :null => false
      t.integer :edition_num,:null => false, :default => 1
      t.integer :status,     :null => false, :default => 1
      t.string  :uuid,       :null => false
      t.timestamps
    end
    set_table_comment(:edition_managements, '版番号管理')
    set_column_comment(:edition_managements, :project_id, 'プロジェクト番号')
    set_column_comment(:edition_managements, :tracker_id, 'トラッカー番号')
    set_column_comment(:edition_managements, :issue_id,   'チケット番号')
    set_column_comment(:edition_managements, :edition_num,'版番号')
    set_column_comment(:edition_managements, :status,     'ステータス')
    set_column_comment(:edition_managements, :uuid,       'Universally Unique Identifier')
  end
end

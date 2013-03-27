# encoding: utf-8
class AddRecordMode < ActiveRecord::Migration
  def change
    add_column :evacuation_advisories, :record_mode, :integer, :null => false, :default => 0
    add_column :shelters             , :record_mode, :integer, :null => false, :default => 0
    add_column :disaster_damages     , :record_mode, :integer, :null => false, :default => 0

    set_column_comment(:evacuation_advisories, :record_mode, "記録種別")
    set_column_comment(:shelters             , :record_mode, "記録種別")
    set_column_comment(:disaster_damages     , :record_mode, "記録種別")
  end
end

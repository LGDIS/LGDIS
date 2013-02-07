# encoding: utf-8
class AddColumnsToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :is_default_all_selected, :boolean
    
    set_column_comment(:custom_fields, :is_default_all_selected, "デフォルト全選択フラグ")
    
    # 手動down時には、以下のSQLを実行
    # ALTER TABLE custom_fields DROP is_default_all_selected
    # DELETE FROM schema_migrations WHERE version = '9-lgdis'
  end
end

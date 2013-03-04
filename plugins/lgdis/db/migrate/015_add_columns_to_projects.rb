# encoding: utf-8
class AddColumnsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :auto_launched, :boolean

    set_column_comment(:projects, :auto_launched, "自動作成フラグ")
  end
end


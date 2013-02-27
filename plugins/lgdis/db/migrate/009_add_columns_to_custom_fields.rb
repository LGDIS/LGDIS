# encoding: utf-8
class AddColumnsToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :include_time, :boolean

    set_column_comment(:custom_fields, :include_time, "時刻有無")
  end
end


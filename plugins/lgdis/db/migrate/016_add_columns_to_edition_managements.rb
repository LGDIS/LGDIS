# encoding: utf-8
class AddColumnsToEditionManagements < ActiveRecord::Migration
  def change
    add_column :edition_managements, :delivery_place_id, :integer

    set_column_comment(:edition_managements, :delivery_place_id, "外部配信先ID")
  end
end



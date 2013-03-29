# encoding: utf-8
class AlterUniqueIndex < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("drop index index_shelters_on_name")
    add_index(:shelters, [:record_mode, :name], :unique => true, :where => 'deleted_at is NULL')
    ActiveRecord::Base.connection.execute("drop index index_evacuation_advisories_on_area")
    add_index(:evacuation_advisories, [:record_mode, :area], :unique => true, :where => 'deleted_at is NULL')
  end
end

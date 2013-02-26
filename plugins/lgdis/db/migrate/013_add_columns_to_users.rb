# encoding: utf-8
class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string

    set_column_comment(:users, :provider, "認可プロバイダ名")
    set_column_comment(:users, :uid, "認可プロバイダのユーザ識別子")

    #remove_index :users, :column => :login
    add_index :users, [:login, :provider, :uid], :unique => true, :name => "index_users_on_uniqueuser"
  end
end


# encoding: utf-8
class AddColumnsToDeliveryHistories < ActiveRecord::Migration
  def change
    add_column :delivery_histories, :request_user_id, :integer
    add_column :delivery_histories, :respond_user_id, :integer
    remove_column :delivery_histories, :request_user
    remove_column :delivery_histories, :respond_user

    set_column_comment(:delivery_histories, :request_user_id, "配信要求者ユーザID")
    set_column_comment(:delivery_histories, :respond_user_id, "配信許可者ユーザID")
  end
end



# -*- coding:utf-8 -*-
class CreateDeliveryHistories < ActiveRecord::Migration
  def change
    create_table :delivery_histories do |t|
      t.integer    "id"
      t.integer    "issue_id"
      t.string     "delivery_place"
      t.string     "request_user"
      t.string     "respond_user"
      t.string     "status"
      t.timestamp  "process_date"

      t.timestamps
    end
    set_table_comment(:delivery_histories, "配信履歴")
    set_column_comment(:delivery_histories, :id,           "ID")
    set_column_comment(:delivery_histories, :issue_id,     "チケット番号")
    set_column_comment(:delivery_histories, :delivery_place, "外部配信先")
    set_column_comment(:delivery_histories, :request_user, "要求者")
    set_column_comment(:delivery_histories, :respond_user, "処理者")
    set_column_comment(:delivery_histories, :status,       "状態")
    set_column_comment(:delivery_histories, :process_date, "処理日")
    set_column_comment(:delivery_histories, :created_at,   "登録日時")
    set_column_comment(:delivery_histories, :updated_at,   "更新日時")
  end
end

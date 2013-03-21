# -*- coding:utf-8 -*-
class CreateDeliveryHistories < ActiveRecord::Migration
  def change
    create_table :delivery_histories do |t|
      t.integer    "id"
      t.integer    "issue_id"
      t.integer    "project_id"
      t.integer    "delivery_place_id"
      t.string     "request_user"
      t.string     "respond_user"
      t.string     "status"
      t.timestamp  "process_date"
      t.string     "mail_subject"
      t.text       "summary"
      t.string     "type_update"
      t.text       "description_cancel"
      t.string     "delivered_area"
      t.timestamp  "published_at"
      t.timestamp  "opened_at"
      t.timestamp  "closed_at"
      t.string     "disaster_info_type"

      t.timestamps
    end
    set_table_comment(:delivery_histories, "配信履歴")
    set_column_comment(:delivery_histories,  :id,                 "ID")
    set_column_comment(:delivery_histories,  :issue_id,           "チケット番号")
    set_column_comment(:delivery_histories,  :project_id,         "プロジェクト番号")
    set_column_comment(:delivery_histories,  :delivery_place_id,  "外部配信先ID")
    set_column_comment(:delivery_histories,  :request_user,       "要求者")
    set_column_comment(:delivery_histories,  :respond_user,       "処理者")
    set_column_comment(:delivery_histories,  :status,             "状態")
    set_column_comment(:delivery_histories,  :process_date,       "処理日")
    set_column_comment(:delivery_histories,  :created_at,         "登録日時")
    set_column_comment(:delivery_histories,  :updated_at,         "更新日時")
    set_column_comment(:delivery_histories,  :mail_subject,       "情報のタイトル")
    set_column_comment(:delivery_histories,  :summary,            "情報の見出し要約文")
    set_column_comment(:delivery_histories,  :type_update,        "情報の更新種別")
    set_column_comment(:delivery_histories,  :description_cancel, "取消の説明文")
    set_column_comment(:delivery_histories,  :published_at,       "情報の発表日時")
    set_column_comment(:delivery_histories,  :delivered_area,     "情報の配信対象地域")
    set_column_comment(:delivery_histories,  :opened_at,          "情報の公開開始日時")
    set_column_comment(:delivery_histories,  :closed_at,          "情報の公開終了日時")
    set_column_comment(:delivery_histories,  :disaster_info_type, "情報の識別区分")
  end
end

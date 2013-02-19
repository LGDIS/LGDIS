# encoding: utf-8
class AddColumnsToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :xml_control, :xml
    add_column :issues, :xml_control_status, :string, :limit => 12
    add_column :issues, :xml_control_editorialoffice, :string, :limit => 50
    add_column :issues, :xml_control_publishingoffice, :string, :limit => 100
    add_column :issues, :xml_control_cause, :string, :limit => 1
    add_column :issues, :xml_control_apply, :string, :limit => 1
    add_column :issues, :xml_head, :xml
    add_column :issues, :xml_head_title, :string, :limit => 100
    add_column :issues, :xml_head_reportdatetime, :datetime
    add_column :issues, :xml_head_targetdatetime, :datetime
    add_column :issues, :xml_head_targetdtdubious, :string, :limit => 8
    add_column :issues, :xml_head_targetduration, :string, :limit => 30
    add_column :issues, :xml_head_validdatetime, :datetime
    add_column :issues, :xml_head_eventid, :string, :limit => 64
    add_column :issues, :xml_head_infotype, :string, :limit => 8
    add_column :issues, :xml_head_serial, :string, :limit => 8
    add_column :issues, :xml_head_infokind, :string, :limit => 100
    add_column :issues, :xml_head_infokindversion, :string, :limit => 12
    add_column :issues, :xml_head_text, :string, :limit => 500
    add_column :issues, :xml_body, :xml
    add_column :issues, :mail_subject,       :string, :limit => 15
    add_column :issues, :summary,            :text
    add_column :issues, :type_update,        :string
    add_column :issues, :description_cancel, :text
    add_column :issues, :published_at,       :datetime
    add_column :issues, :delivered_area,     :string
    add_column :issues, :opened_at,          :datetime
    add_column :issues, :closed_at,          :datetime

    set_column_comment(:issues, :xml_control, "XMLControl部")
    set_column_comment(:issues, :xml_control_status, "運用種別")
    set_column_comment(:issues, :xml_control_editorialoffice, "編集官署名")
    set_column_comment(:issues, :xml_control_publishingoffice, "発表官署名")
    set_column_comment(:issues, :xml_control_cause, "要因")
    set_column_comment(:issues, :xml_control_apply, "承認")
    set_column_comment(:issues, :xml_head, "XMLHead部")
    set_column_comment(:issues, :xml_head_title, "標題")
    set_column_comment(:issues, :xml_head_reportdatetime, "発表時刻")
    set_column_comment(:issues, :xml_head_targetdatetime, "基点時刻")
    set_column_comment(:issues, :xml_head_targetdtdubious, "基点時刻のあいまいさ")
    set_column_comment(:issues, :xml_head_targetduration, "基点時刻からとりうる時間")
    set_column_comment(:issues, :xml_head_validdatetime, "失効時刻")
    set_column_comment(:issues, :xml_head_eventid, "識別情報")
    set_column_comment(:issues, :xml_head_infotype, "情報形態")
    set_column_comment(:issues, :xml_head_serial, "情報番号")
    set_column_comment(:issues, :xml_head_infokind, "スキーマの運用種別情報")
    set_column_comment(:issues, :xml_head_infokindversion, "運用種別情報のバージョン番号")
    set_column_comment(:issues, :xml_head_text, "見出し文")
    set_column_comment(:issues, :xml_body, "XMLBody部")
    set_column_comment(:issues, :mail_subject,       "情報のタイトル")
    set_column_comment(:issues, :summary,            "情報の見出し要約文")
    set_column_comment(:issues, :type_update,        "情報の更新種別")
    set_column_comment(:issues, :description_cancel, "取消の説明文")
    set_column_comment(:issues, :published_at,       "情報の発表日時")
    set_column_comment(:issues, :delivered_area,     "情報の配信対象地域")
    set_column_comment(:issues, :opened_at,          "情報の公開開始日時")
    set_column_comment(:issues, :closed_at,          "情報の公開終了日時")
  end
end

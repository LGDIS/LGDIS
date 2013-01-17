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
    add_column :issues, :xml_head_title, :string, :limit => 500
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
  end
end

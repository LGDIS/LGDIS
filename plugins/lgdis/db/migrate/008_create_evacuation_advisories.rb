# -*- encoding: utf-8 -*-

#TODO:将来的には発令・解除区分のデータ型をRDBMSで対応しているENUM型にする可能性がある｡
  #assumption: svn checkout svn://rubyforge.org/var/svn/enum-column/plugins/enum-column
  #例)       t.enum       :issue_or_lift, :limit => [:a, :b, :c, :d, :e] 

class CreateEvacuationAdvisories < ActiveRecord::Migration
  def change
    create_table :evacuation_advisories do |t|
      #Redmine-app独自のデータ項目
#       t.references :project, :null => false
      #COMMONS定義が自由なためAPPLICを参考にするデータ項目
#       t.string     :disaster_code, :limit => 20, :null => false

      #COMMONS基準のデータ項目
      t.string     :sort_criteria, :limit => 10
      t.string     :issue_or_lift, :limit => 100
      t.string     :area, :limit => 100
      t.string     :area_kana,  :limit => 100
      t.string     :district,  :limit => 10
      t.datetime   :issued_at
      t.datetime   :changed_at 
      t.datetime   :lifted_at
      t.integer    :households
      t.integer    :head_count
      #APPLIC基準のデータ項目
      t.string     :identifier , :limit => 20, :null => false
      t.string     :category, :limit => 2
      t.string     :cause, :limit => 4000	   #, :null => false
      t.string     :advisory_type, :limit => 2, :null => false
       
      t.string     :staff_no, :limit => 10
      t.string     :full_name, :limit => 100
      t.string     :alias, :limit => 100

      t.string     :headline, :limit => 100
      t.string     :message, :limit => 4000
      t.string     :emergency_hq_needed_prefecture, :limit => 100
      t.string     :emergency_hq_needed_city, :limit => 100
      t.string     :alert, :limit => 4000
      t.string     :alerting_area, :limit => 4000
      t.string     :siren_area, :limit => 4000

      t.string     :evacuation_order, :limit => 4000
      t.string     :evacuate_from, :limit => 4000
      t.string     :evacuate_to, :limit => 4000
      t.string     :evacuation_steps_by_authorities, :limit => 4000

      t.string     :remarks, :limit => 4000
      t.timestamp  :deleted_at
      t.timestamps
      
    end

#TODO:将来的には発令・解除区分のデータ型をRDBMSで対応しているENUM型にする可能性がある｡
#     execute <<-SQL
#       ALTER TABLE 'evacuation_advisories' ADD status ENUM('指示等なし','避難準備','避難勧告','避難指示','警戒区域') NOT NULL;
#     SQL

    set_table_comment(:evacuation_advisories, "避難勧告・指示情報")
#     set_column_comment(:evacuation_advisories, :disaster_code, "災害コード")
    set_column_comment(:evacuation_advisories, :sort_criteria, "発令区分")
    set_column_comment(:evacuation_advisories, :issue_or_lift, "発令・解除区分")
    set_column_comment(:evacuation_advisories, :area, "発令・解除地区名称")
    set_column_comment(:evacuation_advisories, :area_kana, "発令・解除地区名称かな")
    set_column_comment(:evacuation_advisories, :district, "地区（大分類）")
    set_column_comment(:evacuation_advisories, :issued_at, "発令日時")
    set_column_comment(:evacuation_advisories, :changed_at, "移行日時")
    set_column_comment(:evacuation_advisories, :lifted_at, "解除日時")
    set_column_comment(:evacuation_advisories, :households, "対象世帯数")
    set_column_comment(:evacuation_advisories, :head_count, "対象人数")
    set_column_comment(:evacuation_advisories, :identifier, " 避難勧告_指示識別情報")
    set_column_comment(:evacuation_advisories, :category, "災害区分")
    set_column_comment(:evacuation_advisories, :cause, "避難原因")
    set_column_comment(:evacuation_advisories, :advisory_type, "避難勧告･指示種別")
  
    set_column_comment(:evacuation_advisories, :staff_no, "発令権限者の職員番号")
    set_column_comment(:evacuation_advisories, :full_name, "発令権限者の氏名")
    set_column_comment(:evacuation_advisories, :alias, "発令権限者の別名称")
  
    set_column_comment(:evacuation_advisories, :headline, "ヘッドライン")
    set_column_comment(:evacuation_advisories, :message, "避難情報文")
    set_column_comment(:evacuation_advisories, :emergency_hq_needed_prefecture, "都道府県緊急対処事態対策本部を設置すべき都道府県")
    set_column_comment(:evacuation_advisories, :emergency_hq_needed_city, "市町村緊急対処事態対策本部を設置すべき市町村")
    set_column_comment(:evacuation_advisories, :alert, "警報内容")
    set_column_comment(:evacuation_advisories, :alerting_area, "警報の通知伝達の対象となる地域の範囲")
    set_column_comment(:evacuation_advisories, :siren_area, "サイレンを使用する地域")
  
    set_column_comment(:evacuation_advisories, :evacuation_order, "避難措置の指示内容")
    set_column_comment(:evacuation_advisories, :evacuate_from, "要避難地域")
    set_column_comment(:evacuation_advisories, :evacuate_to, "避難先地域")
    set_column_comment(:evacuation_advisories, :evacuation_steps_by_authorities, "住民の避難に関して関係機関が講ずべき措置の概要")
  
    set_column_comment(:evacuation_advisories, :remarks, "備考")
    set_column_comment(:evacuation_advisories, :deleted_at, "削除日時")
    set_column_comment(:evacuation_advisories, :created_at, "登録日時")
    set_column_comment(:evacuation_advisories, :updated_at, "更新日時")
  end

end

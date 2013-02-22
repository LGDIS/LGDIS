# encoding: utf-8
class Shelters < ActiveRecord::Migration
  def change
    create_table :shelters do |t|
      t.string     :name, :limit => 30, :null => false
      t.string     :name_kana, :limit => 60
      t.string     :area, :null => false
      t.string     :address, :limit => 200, :null => false
      t.string     :phone, :limit => 20
      t.string     :fax, :limit => 20
      t.string     :e_mail, :limit => 255
      t.string     :person_responsible, :limit => 100
      t.string     :shelter_type, :null => false
      t.string     :shelter_type_detail, :limit => 255
      t.string     :shelter_sort, :null => false
      t.datetime   :opened_at
      t.datetime   :closed_at
      t.integer    :capacity
      t.string     :status
      t.integer    :head_count
      t.integer    :head_count_voluntary
      t.integer    :households
      t.integer    :households_voluntary
      t.datetime   :checked_at
      t.string     :shelter_code, :limit => 20, :null => false
      t.string     :manager_code, :limit => 10
      t.string     :manager_name, :limit => 100
      t.string     :manager_another_name, :limit => 100
      t.datetime   :reported_at
      t.string     :building_damage_info, :limit => 4000
      t.string     :electric_infra_damage_info, :limit => 4000
      t.string     :communication_infra_damage_info, :limit => 4000
      t.string     :other_damage_info, :limit => 4000
      t.string     :usable_flag, :limit => 1
      t.string     :openable_flag, :limit => 1
      t.integer    :injury_count
      t.integer    :upper_care_level_three_count
      t.integer    :elderly_alone_count
      t.integer    :elderly_couple_count
      t.integer    :bedridden_elderly_count
      t.integer    :elderly_dementia_count
      t.integer    :rehabilitation_certificate_count
      t.integer    :physical_disability_certificate_count
      t.string     :note, :limit => 4000
      t.timestamp  :deleted_at
      t.string     :created_by
      t.string     :updated_by
      t.timestamps
    end
    
    add_index(:shelters, :name, :unique => true, :where => 'deleted_at is NULL')
    add_index(:shelters, :shelter_code, :unique => true, :where => 'deleted_at is NULL')
    
    set_table_comment(:shelters, "避難所情報")
    set_column_comment(:shelters, :name, "避難所名")
    set_column_comment(:shelters, :name_kana, "避難所名かな")
    set_column_comment(:shelters, :area, "避難所の地区")
    set_column_comment(:shelters, :address, "避難所の住所")
    set_column_comment(:shelters, :phone, "避難所の電話番号")
    set_column_comment(:shelters, :fax, "避難所のFAX番号")
    set_column_comment(:shelters, :e_mail, "避難所のメールアドレス")
    set_column_comment(:shelters, :person_responsible, "避難所の担当者名")
    set_column_comment(:shelters, :shelter_type, "避難所種別")
    set_column_comment(:shelters, :shelter_type_detail, "避難所種別では表現しきれない情報")
    set_column_comment(:shelters, :shelter_sort, "避難所区分")
    set_column_comment(:shelters, :opened_at, "開設日時")
    set_column_comment(:shelters, :closed_at, "閉鎖日時")
    set_column_comment(:shelters, :capacity, "最大の収容人数")
    set_column_comment(:shelters, :status, "避難所状況")
    set_column_comment(:shelters, :head_count, "人数（自主避難人数を含む）")
    set_column_comment(:shelters, :head_count_voluntary, "自主避難人数")
    set_column_comment(:shelters, :households, "世帯数（自主避難世帯数を含む）")
    set_column_comment(:shelters, :households_voluntary, "自主避難世帯数")
    set_column_comment(:shelters, :checked_at, "避難所状況確認日時")
    set_column_comment(:shelters, :shelter_code, "避難所識別番号")
    set_column_comment(:shelters, :manager_code, "管理者（職員番号）")
    set_column_comment(:shelters, :manager_name, "管理者（名称）")
    set_column_comment(:shelters, :manager_another_name, "管理者（別名）")
    set_column_comment(:shelters, :reported_at, "報告日時")
    set_column_comment(:shelters, :building_damage_info, "建物被害状況")
    set_column_comment(:shelters, :electric_infra_damage_info, "電力被害状況")
    set_column_comment(:shelters, :communication_infra_damage_info, "通信手段被害状況")
    set_column_comment(:shelters, :other_damage_info, "その他の被害")
    set_column_comment(:shelters, :usable_flag, "使用可否")
    set_column_comment(:shelters, :openable_flag, "開設の可否")
    set_column_comment(:shelters, :injury_count, "負傷_計")
    set_column_comment(:shelters, :upper_care_level_three_count, "要介護度3以上_計")
    set_column_comment(:shelters, :elderly_alone_count, "一人暮らし高齢者（65歳以上）_計")
    set_column_comment(:shelters, :elderly_couple_count, "高齢者世帯（夫婦共に65歳以上）_計")
    set_column_comment(:shelters, :bedridden_elderly_count, "寝たきり高齢者_計")
    set_column_comment(:shelters, :elderly_dementia_count, "認知症高齢者_計")
    set_column_comment(:shelters, :rehabilitation_certificate_count, "療育手帳所持者_計")
    set_column_comment(:shelters, :physical_disability_certificate_count, "身体障害者手帳所持者_計")
    set_column_comment(:shelters, :note, "備考")
    set_column_comment(:shelters, :deleted_at, "削除日時")
    set_column_comment(:shelters, :created_by, "登録者")
    set_column_comment(:shelters, :updated_by, "更新者")
    set_column_comment(:shelters, :created_at, "登録日時")
    set_column_comment(:shelters, :updated_at, "更新日時")
  end
end

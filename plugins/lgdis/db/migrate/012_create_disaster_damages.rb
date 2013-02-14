# encoding: utf-8
class CreateDisasterDamages < ActiveRecord::Migration
  def change
    create_table :disaster_damages do |t|
      t.string    :disaster_occurred_location, :limit => 100
      t.datetime  :disaster_occurred_at 
      t.string    :general_disaster_situation, :limit => 4000
      t.integer   :general_dead_count
      t.integer   :general_missing_count
      t.integer   :general_injured_count
      t.integer   :general_complete_collapse_houses_count
      t.integer   :general_partial_damage_houses_count
      t.integer   :general_half_collapse_houses_count
      t.integer   :general_inundation_above_floor_level_houses_count
      t.string    :general_damages_status, :limit => 4000
      t.string    :general_prefectural_antidisaster_headquarter_status, :limit => 4000
      t.datetime  :general_prefectural_antidisaster_headquarter_status_at
      t.string    :general_municipal_antidisaster_headquarter_of, :limit => 12
      t.string    :general_municipal_antidisaster_headquarter_status, :limit => 4000
      t.datetime  :general_municipal_antidisaster_headquarter_status_at
      t.string    :emergency_measures_status, :limit => 4000
      t.integer   :dead_count
      t.integer   :missing_count
      t.integer   :seriously_injured_count
      t.integer   :slightly_injured_count
      t.integer   :complete_collapse_houses_count
      t.integer   :complete_collapse_households_count
      t.integer   :complete_collapse_people_count
      t.integer   :half_collapse_houses_count
      t.integer   :half_collapse_households_count
      t.integer   :half_collapse_people_count
      t.integer   :partial_damage_houses_count
      t.integer   :partial_damage_households_count
      t.integer   :partial_damage_people_count
      t.integer   :inundation_above_floor_level_houses_count
      t.integer   :inundation_above_floor_level_households_count
      t.integer   :inundation_above_floor_level_people_count
      t.integer   :inundation_under_floor_level_houses_count
      t.integer   :inundation_under_floor_level_households_count
      t.integer   :inundation_under_floor_level_people_count
      t.integer   :damaged_public_building_count
      t.integer   :damaged_other_building_count
      t.integer   :buried_or_washed_out_rice_field_ha
      t.integer   :under_water_rice_field_ha
      t.integer   :buried_or_washed_out_upland_field_ha
      t.integer   :under_water_upland_field_ha
      t.integer   :damaged_educational_facilities_count
      t.integer   :damaged_hospitals_count
      t.integer   :damaged_roads_count
      t.integer   :damaged_bridges_count
      t.integer   :damaged_rivers_count
      t.integer   :damaged_harbors_count
      t.integer   :damaged_sand_control_count
      t.integer   :damaged_cleaning_facilities_count
      t.integer   :landslides_count
      t.integer   :closed_lines_count
      t.integer   :damaged_ships_count
      t.integer   :water_failure_houses_count
      t.integer   :dead_telephone_lines_count
      t.integer   :blackout_houses_count
      t.integer   :gas_supply_stopped_houses_count
      t.integer   :damaged_concrete_block_walls_count
      t.integer   :sufferer_houses_count
      t.integer   :sufferer_people_count
      t.integer   :fire_occurred_buildings_count
      t.integer   :fire_occurred_dangerous_substances_count
      t.integer   :fire_occurred_others_count
      t.integer   :public_educational_buildings_losses_amount
      t.integer   :agriculture_forestry_and_fisheries_buildings_losses_amount
      t.integer   :public_civil_buildings_losses_amount
      t.integer   :other_public_buildings_losses_amount
      t.integer   :damaged_public_buildings_municipalities_count
      t.integer   :agriculture_losses_amount
      t.integer   :forestry_losses_amount
      t.integer   :livestock_losses_amount
      t.integer   :fisheries_losses_amount
      t.integer   :commerce_and_industry_losses_amount
      t.integer   :other_losses_amount
      t.string    :prefectural_antidisaster_headquarter_status, :limit => 4000
      t.datetime  :prefectural_antidisaster_headquarter_status_at
      t.string    :municipal_antidisaster_headquarter_of, :limit => 12
      t.string    :municipal_antidisaster_headquarter_type
      t.string    :municipal_antidisaster_headquarter_status
      t.datetime  :municipal_antidisaster_headquarter_status_at
      t.string    :disaster_relief_act_applied_of, :limit => 12
      t.datetime  :disaster_relief_act_applied_at
      t.integer   :disaster_relief_act_applied_municipalities_count
      t.integer   :turnout_fire_station_firefighter_count
      t.integer   :turnout_fire_company_firefighter_count
      t.string    :note_disaster_occurred_location, :limit => 100
      t.string    :note_disaster_occurred_date, :limit => 100
      t.string    :note_disaster_type_outline, :limit => 4000
      t.string    :note_fire_services, :limit => 4000
      t.string    :note_evacuation_advisories, :limit => 4000
      t.string    :note_shelters, :limit => 4000
      t.string    :note_other_local_government, :limit => 4000
      t.string    :note_self_defence_force, :limit => 4000
      t.string    :note_volunteer, :limit => 4000
      t.timestamps
    end
    
    set_table_comment(:disaster_damages, "災害被害情報")
    set_column_comment(:disaster_damages, :disaster_occurred_location, "発生場所")
    set_column_comment(:disaster_damages, :disaster_occurred_at, "発生日時")
    set_column_comment(:disaster_damages, :general_disaster_situation, "災害の概況")
    set_column_comment(:disaster_damages, :general_dead_count, "概況_死傷者_死者")
    set_column_comment(:disaster_damages, :general_missing_count, "概況_死傷者_不明")
    set_column_comment(:disaster_damages, :general_injured_count, "概況_死傷者_負傷者")
    set_column_comment(:disaster_damages, :general_complete_collapse_houses_count, "概況_住家_全壊_棟")
    set_column_comment(:disaster_damages, :general_partial_damage_houses_count, "概況_住家_一部破損_棟")
    set_column_comment(:disaster_damages, :general_half_collapse_houses_count, "概況_住家_半壊_棟")
    set_column_comment(:disaster_damages, :general_inundation_above_floor_level_houses_count, "概況_床上浸水_棟")
    set_column_comment(:disaster_damages, :general_damages_status, "概況_被害の状況")
    set_column_comment(:disaster_damages, :general_prefectural_antidisaster_headquarter_status, "概況_災害対策本部等設置状況_都道府県")
    set_column_comment(:disaster_damages, :general_prefectural_antidisaster_headquarter_status_at, "概況_災害対策本部等設置状況_都道府県_設置状況日時")
    set_column_comment(:disaster_damages, :general_municipal_antidisaster_headquarter_of, "概況_災害対策本部等設置市町村")
    set_column_comment(:disaster_damages, :general_municipal_antidisaster_headquarter_status, "概況_災害対策本部等設置状況_市町村")
    set_column_comment(:disaster_damages, :general_municipal_antidisaster_headquarter_status_at, "概況_災害対策本部等設置状況_市町村_設置状況日時")
    set_column_comment(:disaster_damages, :emergency_measures_status, "応急対策の状況")
    set_column_comment(:disaster_damages, :dead_count, "人的被害_死者")
    set_column_comment(:disaster_damages, :missing_count, "人的被害_行方不明者")
    set_column_comment(:disaster_damages, :seriously_injured_count, "人的被害_重傷者")
    set_column_comment(:disaster_damages, :slightly_injured_count, "人的被害_軽傷者")
    set_column_comment(:disaster_damages, :complete_collapse_houses_count, "住家被害_全壊_棟")
    set_column_comment(:disaster_damages, :complete_collapse_households_count, "住家被害_全壊_世帯")
    set_column_comment(:disaster_damages, :complete_collapse_people_count, "住家被害_全壊_人")
    set_column_comment(:disaster_damages, :half_collapse_houses_count, "住家被害_半壊_棟")
    set_column_comment(:disaster_damages, :half_collapse_households_count, "住家被害_半壊_世帯")
    set_column_comment(:disaster_damages, :half_collapse_people_count, "住家被害_半壊_人")
    set_column_comment(:disaster_damages, :partial_damage_houses_count, "住家被害_一部破損_棟")
    set_column_comment(:disaster_damages, :partial_damage_households_count, "住家被害_一部破損_世帯")
    set_column_comment(:disaster_damages, :partial_damage_people_count, "住家被害_一部破損_人")
    set_column_comment(:disaster_damages, :inundation_above_floor_level_houses_count, "住家被害_床上浸水_棟")
    set_column_comment(:disaster_damages, :inundation_above_floor_level_households_count, "住家被害_床上浸水_世帯")
    set_column_comment(:disaster_damages, :inundation_above_floor_level_people_count, "住家被害_床上浸水_人")
    set_column_comment(:disaster_damages, :inundation_under_floor_level_houses_count, "住家被害_床下浸水_棟")
    set_column_comment(:disaster_damages, :inundation_under_floor_level_households_count, "住家被害_床下浸水_世帯")
    set_column_comment(:disaster_damages, :inundation_under_floor_level_people_count, "住家被害_床下浸水_人")
    set_column_comment(:disaster_damages, :damaged_public_building_count, "非住家被害_公共建物_棟")
    set_column_comment(:disaster_damages, :damaged_other_building_count, "非住家被害_その他_棟")
    set_column_comment(:disaster_damages, :buried_or_washed_out_rice_field_ha, "その他被害_田流出埋没_ha")
    set_column_comment(:disaster_damages, :under_water_rice_field_ha, "その他被害_田冠水_ha")
    set_column_comment(:disaster_damages, :buried_or_washed_out_upland_field_ha, "その他被害_畑流出埋没_ha")
    set_column_comment(:disaster_damages, :under_water_upland_field_ha, "その他被害_畑冠水_ha")
    set_column_comment(:disaster_damages, :damaged_educational_facilities_count, "その他被害_文教施設_箇所")
    set_column_comment(:disaster_damages, :damaged_hospitals_count, "その他被害_病院_箇所")
    set_column_comment(:disaster_damages, :damaged_roads_count, "その他被害_道路_箇所")
    set_column_comment(:disaster_damages, :damaged_bridges_count, "その他被害_橋梁_箇所")
    set_column_comment(:disaster_damages, :damaged_rivers_count, "その他被害_河川_箇所")
    set_column_comment(:disaster_damages, :damaged_harbors_count, "その他被害_港湾_箇所")
    set_column_comment(:disaster_damages, :damaged_sand_control_count, "その他被害_砂防_箇所")
    set_column_comment(:disaster_damages, :damaged_cleaning_facilities_count, "その他被害_清掃施設_箇所")
    set_column_comment(:disaster_damages, :landslides_count, "その他被害_崖くずれ_箇所")
    set_column_comment(:disaster_damages, :closed_lines_count, "その他被害_鉄道不通_箇所")
    set_column_comment(:disaster_damages, :damaged_ships_count, "その他被害_被害船舶_隻")
    set_column_comment(:disaster_damages, :water_failure_houses_count, "その他被害_水道断水_戸数")
    set_column_comment(:disaster_damages, :dead_telephone_lines_count, "その他被害_不通電話_回線")
    set_column_comment(:disaster_damages, :blackout_houses_count, "その他被害_停電_戸数")
    set_column_comment(:disaster_damages, :gas_supply_stopped_houses_count, "その他被害_ガス供給停止_戸数")
    set_column_comment(:disaster_damages, :damaged_concrete_block_walls_count, "その他被害_ブロック塀_箇所")
    set_column_comment(:disaster_damages, :sufferer_houses_count, "り災世帯数")
    set_column_comment(:disaster_damages, :sufferer_people_count, "り災者数")
    set_column_comment(:disaster_damages, :fire_occurred_buildings_count, "火災発生_建物_件数")
    set_column_comment(:disaster_damages, :fire_occurred_dangerous_substances_count, "火災発生_危険物_件数")
    set_column_comment(:disaster_damages, :fire_occurred_others_count, "火災発生_その他_件数")
    set_column_comment(:disaster_damages, :public_educational_buildings_losses_amount, "公立文教施設_被害額（千円）")
    set_column_comment(:disaster_damages, :agriculture_forestry_and_fisheries_buildings_losses_amount, "農林水産施設_被害額（千円）")
    set_column_comment(:disaster_damages, :public_civil_buildings_losses_amount, "公立土木施設_被害額（千円）")
    set_column_comment(:disaster_damages, :other_public_buildings_losses_amount, "その他公共施設_被害額（千円）")
    set_column_comment(:disaster_damages, :damaged_public_buildings_municipalities_count, "公共施設被害市町村数")
    set_column_comment(:disaster_damages, :agriculture_losses_amount, "農業被害額（千円）")
    set_column_comment(:disaster_damages, :forestry_losses_amount, "林業被害額（千円）")
    set_column_comment(:disaster_damages, :livestock_losses_amount, "畜産被害額（千円）")
    set_column_comment(:disaster_damages, :fisheries_losses_amount, "水産被害額（千円）")
    set_column_comment(:disaster_damages, :commerce_and_industry_losses_amount, "商工被害額（千円）")
    set_column_comment(:disaster_damages, :other_losses_amount, "その他被害額（千円）")
    set_column_comment(:disaster_damages, :prefectural_antidisaster_headquarter_status, "災害対策本部等設置状況_都道府県")
    set_column_comment(:disaster_damages, :prefectural_antidisaster_headquarter_status_at, "災害対策本部等設置状況_都道府県_設置状況日時")
    set_column_comment(:disaster_damages, :municipal_antidisaster_headquarter_of, "災害対策本部等設置市町村")
    set_column_comment(:disaster_damages, :municipal_antidisaster_headquarter_type, "災害対策本部等設置状況_市町村_本部種別")
    set_column_comment(:disaster_damages, :municipal_antidisaster_headquarter_status, "災害対策本部等設置状況_市町村")
    set_column_comment(:disaster_damages, :municipal_antidisaster_headquarter_status_at, "災害対策本部等設置状況_市町村_設置状況日時")
    set_column_comment(:disaster_damages, :disaster_relief_act_applied_of, "災害救助法適用市町村_消防本部名")
    set_column_comment(:disaster_damages, :disaster_relief_act_applied_at, "災害救助法適用日時")
    set_column_comment(:disaster_damages, :disaster_relief_act_applied_municipalities_count, "災害救助法適用市町村数")
    set_column_comment(:disaster_damages, :turnout_fire_station_firefighter_count, "消防職員出勤延人数")
    set_column_comment(:disaster_damages, :turnout_fire_company_firefighter_count, "消防団員出勤延人数")
    set_column_comment(:disaster_damages, :note_disaster_occurred_location, "備考（災害発生場所）")
    set_column_comment(:disaster_damages, :note_disaster_occurred_date, "備考（災害発生年月日）")
    set_column_comment(:disaster_damages, :note_disaster_type_outline, "備考（災害種類概況）")
    set_column_comment(:disaster_damages, :note_fire_services, "備考（消防_水防_救急_救助等消防機関の活動状況）")
    set_column_comment(:disaster_damages, :note_evacuation_advisories, "備考（避難勧告_指示の状況）")
    set_column_comment(:disaster_damages, :note_shelters, "備考（避難所の設置状況）")
    set_column_comment(:disaster_damages, :note_other_local_government, "備考（他の地方公共団体への応援要請_応援活動の状況）")
    set_column_comment(:disaster_damages, :note_self_defence_force, "備考（自衛隊の派遣要請_出勤状況）")
    set_column_comment(:disaster_damages, :note_volunteer, "備考（災害ボランティアの活動状況）")
    set_column_comment(:disaster_damages, :created_at, "登録日時")
    set_column_comment(:disaster_damages, :updated_at, "更新日時")
  end
end

# -*- coding:utf-8 -*-
require 'spec_helper'

describe DisasterDamage do
  CONST = Constant::hash_for_table(DisasterDamage.table_name).freeze
  before do
    User.current = nil # 一度設定されたcurrent_userが保持されるのでここでnilに設定
    @project = FactoryGirl.build(:project1, :id => 5)
    @project.save!
    @issue = FactoryGirl.create(:issue1, :project_id=>@project.id)
    @issue.save!
    
    @disaster_damage = DisasterDamage.new
    
    @disaster_damage.id                                                         = 1
    @disaster_damage.disaster_occurred_location                                 = "発生場所"
    @disaster_damage.disaster_occurred_at                                       = "2001-01-02 03:04"
    @disaster_damage.general_disaster_situation                                 = "災害の状況"
    @disaster_damage.general_dead_count                                         = 2
    @disaster_damage.general_missing_count                                      = 3
    @disaster_damage.general_injured_count                                      = 4
    @disaster_damage.general_complete_collapse_houses_count                     = 5
    @disaster_damage.general_partial_damage_houses_count                        = 6
    @disaster_damage.general_half_collapse_houses_count                         = 7
    @disaster_damage.general_inundation_above_floor_level_houses_count          = 8
    @disaster_damage.general_damages_status                                     = "概況_被害の状況"
    @disaster_damage.general_prefectural_antidisaster_headquarter_status        = "概況_災害対策本部等設置状況_都道府県"
    @disaster_damage.general_prefectural_antidisaster_headquarter_status_at     = "2002-02-03 04:05"
    @disaster_damage.general_municipal_antidisaster_headquarter_of              = "災対本市町村" # 概況_災害対策本部等設置市町村
    @disaster_damage.general_municipal_antidisaster_headquarter_status          = "概況_災害対策本部等設置状況_市町村"
    @disaster_damage.general_municipal_antidisaster_headquarter_status_at       = "2003-03-04 05:06"
    @disaster_damage.emergency_measures_status                                  = "応急対策の状況"
    @disaster_damage.dead_count                                                 = 9
    @disaster_damage.missing_count                                              = 10
    @disaster_damage.seriously_injured_count                                    = 11
    @disaster_damage.slightly_injured_count                                     = 12
    @disaster_damage.complete_collapse_houses_count                             = 13
    @disaster_damage.complete_collapse_households_count                         = 14
    @disaster_damage.complete_collapse_people_count                             = 15
    @disaster_damage.half_collapse_houses_count                                 = 16
    @disaster_damage.half_collapse_households_count                             = 17
    @disaster_damage.half_collapse_people_count                                 = 18
    @disaster_damage.partial_damage_houses_count                                = 19
    @disaster_damage.partial_damage_households_count                            = 20
    @disaster_damage.partial_damage_people_count                                = 21
    @disaster_damage.inundation_above_floor_level_houses_count                  = 22
    @disaster_damage.inundation_above_floor_level_households_count              = 23
    @disaster_damage.inundation_above_floor_level_people_count                  = 24
    @disaster_damage.inundation_under_floor_level_houses_count                  = 25
    @disaster_damage.inundation_under_floor_level_households_count              = 26
    @disaster_damage.inundation_under_floor_level_people_count                  = 27
    @disaster_damage.damaged_public_building_count                              = 28
    @disaster_damage.damaged_other_building_count                               = 29
    @disaster_damage.buried_or_washed_out_rice_field_ha                         = 30
    @disaster_damage.under_water_rice_field_ha                                  = 31
    @disaster_damage.buried_or_washed_out_upland_field_ha                       = 32
    @disaster_damage.under_water_upland_field_ha                                = 33
    @disaster_damage.damaged_educational_facilities_count                       = 34
    @disaster_damage.damaged_hospitals_count                                    = 35
    @disaster_damage.damaged_roads_count                                        = 36
    @disaster_damage.damaged_bridges_count                                      = 37
    @disaster_damage.damaged_rivers_count                                       = 38
    @disaster_damage.damaged_harbors_count                                      = 39
    @disaster_damage.damaged_sand_control_count                                 = 40
    @disaster_damage.damaged_cleaning_facilities_count                          = 41
    @disaster_damage.landslides_count                                           = 42
    @disaster_damage.closed_lines_count                                         = 43
    @disaster_damage.damaged_ships_count                                        = 44
    @disaster_damage.water_failure_houses_count                                 = 45
    @disaster_damage.dead_telephone_lines_count                                 = 46
    @disaster_damage.blackout_houses_count                                      = 47
    @disaster_damage.gas_supply_stopped_houses_count                            = 48
    @disaster_damage.damaged_concrete_block_walls_count                         = 49
    @disaster_damage.sufferer_houses_count                                      = 50
    @disaster_damage.sufferer_people_count                                      = 51
    @disaster_damage.fire_occurred_buildings_count                              = 52
    @disaster_damage.fire_occurred_dangerous_substances_count                   = 53
    @disaster_damage.fire_occurred_others_count                                 = 54
    @disaster_damage.public_educational_buildings_losses_amount                 = 55
    @disaster_damage.agriculture_forestry_and_fisheries_buildings_losses_amount = 100
    @disaster_damage.public_civil_buildings_losses_amount                       = 101
    @disaster_damage.other_public_buildings_losses_amount                       = 102
    @disaster_damage.damaged_public_buildings_municipalities_count              = 56
    @disaster_damage.agriculture_losses_amount                                  = 103
    @disaster_damage.forestry_losses_amount                                     = 104
    @disaster_damage.livestock_losses_amount                                    = 105
    @disaster_damage.fisheries_losses_amount                                    = 106
    @disaster_damage.commerce_and_industry_losses_amount                        = 107
    @disaster_damage.other_losses_amount                                        = 108
    @disaster_damage.prefectural_antidisaster_headquarter_status                = "災害対策本部等設置状況_都道府県"
    @disaster_damage.prefectural_antidisaster_headquarter_status_at             = "2004-04-05 06:07"
    @disaster_damage.municipal_antidisaster_headquarter_of                      = "災対本市町村" # 災害対策本部等設置市町村
    @disaster_damage.municipal_antidisaster_headquarter_type                    = "2" # 2:対策本部     災害対策本部等設置状況_市町村_本部種別
    @disaster_damage.municipal_antidisaster_headquarter_status                  = "1" # 1:解散         災害対策本部等設置状況_市町村
    @disaster_damage.municipal_antidisaster_headquarter_status_at               = "2005-05-06 07:08"
    @disaster_damage.disaster_relief_act_applied_of                             = "災救村消防名" # 災害救助法適用市町村_消防本部名
    @disaster_damage.disaster_relief_act_applied_at                             = "2006-06-07 08:09"
    @disaster_damage.disaster_relief_act_applied_municipalities_count           = 57
    @disaster_damage.turnout_fire_station_firefighter_count                     = 58
    @disaster_damage.turnout_fire_company_firefighter_count                     = 59
    @disaster_damage.note_disaster_occurred_location                            = "備考（災害発生場所）"
    @disaster_damage.note_disaster_occurred_date                                = "備考（災害発生年月日）"
    @disaster_damage.note_disaster_type_outline                                 = "備考（災害種類概況）"
    @disaster_damage.note_fire_services                                         = "備考（消防_水防_救急_救助等消防機関の活動状況）"
    @disaster_damage.note_evacuation_advisories                                 = "備考（避難勧告_指示の状況）"
    @disaster_damage.note_shelters                                              = "備考（避難所の設置状況）"
    @disaster_damage.note_other_local_government                                = "備考（他の地方公共団体への応援要請_応援活動の状況）"
    @disaster_damage.note_self_defence_force                                    = "備考（自衛隊の派遣要請_出勤状況）"
    @disaster_damage.note_volunteer                                             = "備考（災害ボランティアの活動状況）"
 end
  
  describe "Validation " do
    describe "Validation OK" do
      before do
      end
      it "save success" do
        @disaster_damage.save.should be_true
      end
    end
    describe "Validation disaster_occurred_location length 100 over" do
      before do
        @disaster_damage.disaster_occurred_location = "L"*101
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_disaster_situation length 4000 over" do
      before do
        @disaster_damage.general_disaster_situation = "G"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_dead_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.general_dead_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_dead_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.general_dead_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_missing_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.general_missing_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_missing_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.general_missing_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_injured_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.general_injured_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_injured_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.general_injured_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_complete_collapse_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.general_complete_collapse_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_complete_collapse_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.general_complete_collapse_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_partial_damage_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.general_partial_damage_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_partial_damage_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.general_partial_damage_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_half_collapse_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.general_half_collapse_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_half_collapse_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.general_half_collapse_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_inundation_above_floor_level_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.general_inundation_above_floor_level_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_inundation_above_floor_level_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.general_inundation_above_floor_level_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_damages_status length 4000 over" do
      before do
        @disaster_damage.general_damages_status = "G"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_prefectural_antidisaster_headquarter_status length 4000 over" do
      before do
        @disaster_damage.general_prefectural_antidisaster_headquarter_status = "G"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_municipal_antidisaster_headquarter_of length 12 over" do
      before do
        @disaster_damage.general_municipal_antidisaster_headquarter_of = "G"*13
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation general_municipal_antidisaster_headquarter_status length 4000 over" do
      before do
        @disaster_damage.general_municipal_antidisaster_headquarter_status = "G"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation emergency_measures_status length 4000 over" do
      before do
        @disaster_damage.emergency_measures_status = "E"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation dead_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.dead_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation dead_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.dead_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation missing_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.missing_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation missing_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.missing_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation seriously_injured_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.seriously_injured_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation seriously_injured_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.seriously_injured_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation slightly_injured_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.slightly_injured_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation slightly_injured_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.slightly_injured_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation complete_collapse_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.complete_collapse_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation complete_collapse_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.complete_collapse_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation complete_collapse_households_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.complete_collapse_households_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation complete_collapse_households_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.complete_collapse_households_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation complete_collapse_people_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.complete_collapse_people_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation complete_collapse_people_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.complete_collapse_people_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation half_collapse_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.half_collapse_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation half_collapse_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.half_collapse_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation half_collapse_households_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.half_collapse_households_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation half_collapse_households_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.half_collapse_households_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation half_collapse_people_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.half_collapse_people_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation half_collapse_people_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.half_collapse_people_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation partial_damage_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.partial_damage_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation partial_damage_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.partial_damage_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation partial_damage_households_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.partial_damage_households_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation partial_damage_households_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.partial_damage_households_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation partial_damage_people_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.partial_damage_people_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation partial_damage_people_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.partial_damage_people_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation inundation_above_floor_level_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.inundation_above_floor_level_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation inundation_above_floor_level_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.inundation_above_floor_level_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation inundation_above_floor_level_households_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.inundation_above_floor_level_households_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation inundation_above_floor_level_households_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.inundation_above_floor_level_households_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation inundation_above_floor_level_people_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.inundation_above_floor_level_people_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation inundation_above_floor_level_people_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.inundation_above_floor_level_people_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation inundation_under_floor_level_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.inundation_under_floor_level_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation inundation_under_floor_level_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.inundation_under_floor_level_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation inundation_under_floor_level_households_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.inundation_under_floor_level_households_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation inundation_under_floor_level_households_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.inundation_under_floor_level_households_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation inundation_under_floor_level_people_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.inundation_under_floor_level_people_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation inundation_under_floor_level_people_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.inundation_under_floor_level_people_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_public_building_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_public_building_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_public_building_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_public_building_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_other_building_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_other_building_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_other_building_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_other_building_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation buried_or_washed_out_rice_field_ha not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.buried_or_washed_out_rice_field_ha = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation buried_or_washed_out_rice_field_ha not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.buried_or_washed_out_rice_field_ha = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation under_water_rice_field_ha not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.under_water_rice_field_ha = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation under_water_rice_field_ha not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.under_water_rice_field_ha = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation buried_or_washed_out_upland_field_ha not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.buried_or_washed_out_upland_field_ha = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation buried_or_washed_out_upland_field_ha not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.buried_or_washed_out_upland_field_ha = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation under_water_upland_field_ha not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.under_water_upland_field_ha = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation under_water_upland_field_ha not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.under_water_upland_field_ha = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_educational_facilities_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_educational_facilities_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_educational_facilities_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_educational_facilities_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_hospitals_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_hospitals_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_hospitals_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_hospitals_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_roads_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_roads_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_roads_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_roads_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_bridges_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_bridges_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_bridges_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_bridges_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_rivers_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_rivers_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_rivers_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_rivers_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_harbors_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_harbors_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_harbors_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_harbors_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_sand_control_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_sand_control_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_sand_control_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_sand_control_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_cleaning_facilities_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_cleaning_facilities_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_cleaning_facilities_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_cleaning_facilities_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation landslides_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.landslides_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation landslides_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.landslides_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation closed_lines_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.closed_lines_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation closed_lines_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.closed_lines_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_ships_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_ships_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_ships_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_ships_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation water_failure_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.water_failure_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation water_failure_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.water_failure_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation dead_telephone_lines_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.dead_telephone_lines_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation dead_telephone_lines_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.dead_telephone_lines_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation blackout_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.blackout_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation blackout_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.blackout_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation gas_supply_stopped_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.gas_supply_stopped_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation gas_supply_stopped_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.gas_supply_stopped_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_concrete_block_walls_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_concrete_block_walls_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_concrete_block_walls_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_concrete_block_walls_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation sufferer_houses_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.sufferer_houses_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation sufferer_houses_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.sufferer_houses_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation sufferer_people_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.sufferer_people_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation sufferer_people_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.sufferer_people_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation fire_occurred_buildings_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.fire_occurred_buildings_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation fire_occurred_buildings_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.fire_occurred_buildings_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation fire_occurred_dangerous_substances_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.fire_occurred_dangerous_substances_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation fire_occurred_dangerous_substances_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.fire_occurred_dangerous_substances_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation fire_occurred_others_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.fire_occurred_others_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation fire_occurred_others_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.fire_occurred_others_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation public_educational_buildings_losses_amount not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.public_educational_buildings_losses_amount = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation public_educational_buildings_losses_amount not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.public_educational_buildings_losses_amount = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation agriculture_forestry_and_fisheries_buildings_losses_amount not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.agriculture_forestry_and_fisheries_buildings_losses_amount = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation agriculture_forestry_and_fisheries_buildings_losses_amount not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.agriculture_forestry_and_fisheries_buildings_losses_amount = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation public_civil_buildings_losses_amount not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.public_civil_buildings_losses_amount = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation public_civil_buildings_losses_amount not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.public_civil_buildings_losses_amount = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation other_public_buildings_losses_amount not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.other_public_buildings_losses_amount = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation other_public_buildings_losses_amount not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.other_public_buildings_losses_amount = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_public_buildings_municipalities_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.damaged_public_buildings_municipalities_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation damaged_public_buildings_municipalities_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.damaged_public_buildings_municipalities_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation agriculture_losses_amount not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.agriculture_losses_amount = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation agriculture_losses_amount not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.agriculture_losses_amount = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation forestry_losses_amount not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.forestry_losses_amount = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation forestry_losses_amount not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.forestry_losses_amount = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation livestock_losses_amount not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.livestock_losses_amount = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation livestock_losses_amount not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.livestock_losses_amount = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation fisheries_losses_amount not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.fisheries_losses_amount = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation fisheries_losses_amount not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.fisheries_losses_amount = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation commerce_and_industry_losses_amount not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.commerce_and_industry_losses_amount = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation commerce_and_industry_losses_amount not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.commerce_and_industry_losses_amount = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation other_losses_amount not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.other_losses_amount = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation other_losses_amount not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.other_losses_amount = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation prefectural_antidisaster_headquarter_status length 4000 over" do
      before do
        @disaster_damage.prefectural_antidisaster_headquarter_status = "P"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation municipal_antidisaster_headquarter_of length 12 over" do
      before do
        @disaster_damage.municipal_antidisaster_headquarter_of = "M"*13
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation municipal_antidisaster_headquarter_type not specified value" do
      before do
        @disaster_damage.municipal_antidisaster_headquarter_type = "A"
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation municipal_antidisaster_headquarter_status not specified value" do
      before do
        @disaster_damage.municipal_antidisaster_headquarter_status = "A"
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation disaster_relief_act_applied_of length 12 over" do
      before do
        @disaster_damage.disaster_relief_act_applied_of = "D"*13
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation disaster_relief_act_applied_municipalities_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.disaster_relief_act_applied_municipalities_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation disaster_relief_act_applied_municipalities_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.disaster_relief_act_applied_municipalities_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation turnout_fire_station_firefighter_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.turnout_fire_station_firefighter_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation turnout_fire_station_firefighter_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.turnout_fire_station_firefighter_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation turnout_fire_company_firefighter_count not POSITIVE_INTEGER over value" do
      before do
        @disaster_damage.turnout_fire_company_firefighter_count = 2147483647 +1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation turnout_fire_company_firefighter_count not POSITIVE_INTEGER minus value" do
      before do
        @disaster_damage.turnout_fire_company_firefighter_count = -1
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation note_disaster_occurred_location length 100 over" do
      before do
        @disaster_damage.note_disaster_occurred_location = "N"*101
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation note_disaster_occurred_date length 100 over" do
      before do
        @disaster_damage.note_disaster_occurred_date = "N"*101
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation note_disaster_type_outline length 4000 over" do
      before do
        @disaster_damage.note_disaster_type_outline = "G"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation note_fire_services length 4000 over" do
      before do
        @disaster_damage.note_fire_services = "G"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation note_evacuation_advisories length 4000 over" do
      before do
        @disaster_damage.note_evacuation_advisories = "G"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation note_shelters length 4000 over" do
      before do
        @disaster_damage.note_shelters = "G"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation note_other_local_government length 4000 over" do
      before do
        @disaster_damage.note_other_local_government = "G"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation note_self_defence_force length 4000 over" do
      before do
        @disaster_damage.note_self_defence_force = "G"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
    describe "Validation note_volunteer length 4000 over" do
      before do
        @disaster_damage.note_volunteer = "G"*4001
      end
      it "save failure" do
        @disaster_damage.save.should be_false
      end
    end
  end


  describe "#human_attribute_name" do
    it "return localize field name" do
      DisasterDamage.human_attribute_name(:field_disaster_occurred_location).should == "その１（災害概況即報） / 災害の概況 / 発生場所"
      DisasterDamage.human_attribute_name(:field_disaster_occurred_at).should == "その１（災害概況即報） / 災害の概況 / 発生日時"
      DisasterDamage.human_attribute_name(:field_general_disaster_situation).should == "その１（災害概況即報） / 災害の概況"
      DisasterDamage.human_attribute_name(:field_general_dead_count).should == "その１（災害概況即報） / 被害の状況 / 死傷者 / 死者（人）"
      DisasterDamage.human_attribute_name(:field_general_missing_count).should == "その１（災害概況即報） / 被害の状況 / 死傷者 / 不明（人）"
      DisasterDamage.human_attribute_name(:field_general_injured_count).should == "その１（災害概況即報） / 被害の状況 / 死傷者 / 負傷者（人）"
      DisasterDamage.human_attribute_name(:field_general_complete_collapse_houses_count).should == "その１（災害概況即報） / 被害の状況 / 住家 / 全壊（棟）"
      DisasterDamage.human_attribute_name(:field_general_partial_damage_houses_count).should == "その１（災害概況即報） / 被害の状況 / 住家 / 一部破損（棟）"
      DisasterDamage.human_attribute_name(:field_general_half_collapse_houses_count).should == "その１（災害概況即報） / 被害の状況 / 住家 / 半壊（棟）"
      DisasterDamage.human_attribute_name(:field_general_inundation_above_floor_level_houses_count).should == "その１（災害概況即報） / 被害の状況 / 住家 / 床上浸水（棟）"
      DisasterDamage.human_attribute_name(:field_general_damages_status).should == "その１（災害概況即報） / 被害の状況"
      DisasterDamage.human_attribute_name(:field_general_prefectural_antidisaster_headquarter_status).should == "その１（災害概況即報） / 応急対策の状況 / 災害対策本部等の設置状況 / （都道府県）"
      DisasterDamage.human_attribute_name(:field_general_prefectural_antidisaster_headquarter_status_at).should == "その１（災害概況即報） / 応急対策の状況 / 災害対策本部等の設置状況 / （都道府県） / 設置状況日時"
      DisasterDamage.human_attribute_name(:field_general_municipal_antidisaster_headquarter_of).should == "その１（災害概況即報） / 応急対策の状況 / 災害対策本部等の設置状況 / （市町村） / 設置市町村"
      DisasterDamage.human_attribute_name(:field_general_municipal_antidisaster_headquarter_status).should == "その１（災害概況即報） / 応急対策の状況 / 災害対策本部等の設置状況 / （市町村）"
      DisasterDamage.human_attribute_name(:field_general_municipal_antidisaster_headquarter_status_at).should == "その１（災害概況即報） / 応急対策の状況 / 災害対策本部等の設置状況 / （市町村） / 設置状況日時"
      DisasterDamage.human_attribute_name(:field_emergency_measures_status).should == "その１（災害概況即報） / 応急対策の状況"
      DisasterDamage.human_attribute_name(:field_dead_count).should == "その２（被害状況即報） / 人的被害 / 死者（人）"
      DisasterDamage.human_attribute_name(:field_missing_count).should == "その２（被害状況即報） / 人的被害 / 行方不明者（人）"
      DisasterDamage.human_attribute_name(:field_seriously_injured_count).should == "その２（被害状況即報） / 人的被害 / 負傷者 / 重傷（人）"
      DisasterDamage.human_attribute_name(:field_slightly_injured_count).should == "その２（被害状況即報） / 人的被害 / 負傷者 / 軽傷（人）"
      DisasterDamage.human_attribute_name(:field_complete_collapse_houses_count).should == "その２（被害状況即報） / 住家被害 / 全壊（棟）"
      DisasterDamage.human_attribute_name(:field_complete_collapse_households_count).should == "その２（被害状況即報） / 住家被害 / 全壊（世帯）"
      DisasterDamage.human_attribute_name(:field_complete_collapse_people_count).should == "その２（被害状況即報） / 住家被害 / 全壊（人）"
      DisasterDamage.human_attribute_name(:field_half_collapse_houses_count).should == "その２（被害状況即報） / 住家被害 / 半壊（棟）"
      DisasterDamage.human_attribute_name(:field_half_collapse_households_count).should == "その２（被害状況即報） / 住家被害 / 半壊（世帯）"
      DisasterDamage.human_attribute_name(:field_half_collapse_people_count).should == "その２（被害状況即報） / 住家被害 / 半壊（人）"
      DisasterDamage.human_attribute_name(:field_partial_damage_houses_count).should == "その２（被害状況即報） / 住家被害 / 一部破損（棟）"
      DisasterDamage.human_attribute_name(:field_partial_damage_households_count).should == "その２（被害状況即報） / 住家被害 / 一部破損（世帯）"
      DisasterDamage.human_attribute_name(:field_partial_damage_people_count).should == "その２（被害状況即報） / 住家被害 / 一部破損（人）"
      DisasterDamage.human_attribute_name(:field_inundation_above_floor_level_houses_count).should == "その２（被害状況即報） / 住家被害 / 床上浸水（棟）"
      DisasterDamage.human_attribute_name(:field_inundation_above_floor_level_households_count).should == "その２（被害状況即報） / 住家被害 / 床上浸水（世帯）"
      DisasterDamage.human_attribute_name(:field_inundation_above_floor_level_people_count).should == "その２（被害状況即報） / 住家被害 / 床上浸水（人）"
      DisasterDamage.human_attribute_name(:field_inundation_under_floor_level_houses_count).should == "その２（被害状況即報） / 住家被害 / 床下浸水（棟）"
      DisasterDamage.human_attribute_name(:field_inundation_under_floor_level_households_count).should == "その２（被害状況即報） / 住家被害 / 床下浸水（世帯）"
      DisasterDamage.human_attribute_name(:field_inundation_under_floor_level_people_count).should == "その２（被害状況即報） / 住家被害 / 床下浸水（人）"
      DisasterDamage.human_attribute_name(:field_damaged_public_building_count).should == "その２（被害状況即報） / 非住家被害 / 公共建物（棟）"
      DisasterDamage.human_attribute_name(:field_damaged_other_building_count).should == "その２（被害状況即報） / 非住家被害 / その他（棟）"
      DisasterDamage.human_attribute_name(:field_buried_or_washed_out_rice_field_ha).should == "その２（被害状況即報） / その他 / 田 / 流出・埋没（ha）"
      DisasterDamage.human_attribute_name(:field_under_water_rice_field_ha).should == "その２（被害状況即報） / その他 / 田 / 冠水（ha）"
      DisasterDamage.human_attribute_name(:field_buried_or_washed_out_upland_field_ha).should == "その２（被害状況即報） / その他 / 畑 / 流出・埋没（ha）"
      DisasterDamage.human_attribute_name(:field_under_water_upland_field_ha).should == "その２（被害状況即報） / その他 / 畑 / 冠水（ha）"
      DisasterDamage.human_attribute_name(:field_damaged_educational_facilities_count).should == "その２（被害状況即報） / その他 / 文教施設（箇所）"
      DisasterDamage.human_attribute_name(:field_damaged_hospitals_count).should == "その２（被害状況即報） / その他 / 病院（箇所）"
      DisasterDamage.human_attribute_name(:field_damaged_roads_count).should == "その２（被害状況即報） / その他 / 道路（箇所）"
      DisasterDamage.human_attribute_name(:field_damaged_bridges_count).should == "そその２（被害状況即報） / その他 / 橋りょう（箇所）"
      DisasterDamage.human_attribute_name(:field_damaged_rivers_count).should == "その２（被害状況即報） / その他 / 河川（箇所）"
      DisasterDamage.human_attribute_name(:field_damaged_harbors_count).should == "その２（被害状況即報） / その他 / 港湾（箇所）"
      DisasterDamage.human_attribute_name(:field_damaged_sand_control_count).should == "その２（被害状況即報） / その他 / 砂防（箇所）"
      DisasterDamage.human_attribute_name(:field_damaged_cleaning_facilities_count).should == "その２（被害状況即報） / その他 / 清掃施設（箇所）"
      DisasterDamage.human_attribute_name(:field_landslides_count).should == "その２（被害状況即報） / その他 / 崖くずれ（箇所）"
      DisasterDamage.human_attribute_name(:field_closed_lines_count).should == "その２（被害状況即報） / その他 / 鉄道不通（箇所）"
      DisasterDamage.human_attribute_name(:field_damaged_ships_count).should == "その２（被害状況即報） / その他 / 被害船舶（隻）"
      DisasterDamage.human_attribute_name(:field_water_failure_houses_count).should == "その２（被害状況即報） / その他 / 水道（戸）"
      DisasterDamage.human_attribute_name(:field_dead_telephone_lines_count).should == "その２（被害状況即報） / その他 / 電話（回線）"
      DisasterDamage.human_attribute_name(:field_blackout_houses_count).should == "その２（被害状況即報） / その他 / 電気（戸）"
      DisasterDamage.human_attribute_name(:field_gas_supply_stopped_houses_count).should == "その２（被害状況即報） / その他 / ガス（戸）"
      DisasterDamage.human_attribute_name(:field_damaged_concrete_block_walls_count).should == "その２（被害状況即報） / その他 / ブロック塀等（箇所）"
      DisasterDamage.human_attribute_name(:field_sufferer_houses_count).should == "その２（被害状況即報） / り災世帯数（世帯）"
      DisasterDamage.human_attribute_name(:field_sufferer_people_count).should == "その２（被害状況即報） / り災者数（人）"
      DisasterDamage.human_attribute_name(:field_fire_occurred_buildings_count).should == "その２（被害状況即報） / 火災発生 / 建物（件）"
      DisasterDamage.human_attribute_name(:field_fire_occurred_dangerous_substances_count).should == "その２（被害状況即報） / 火災発生 / 危険物（件）"
      DisasterDamage.human_attribute_name(:field_fire_occurred_others_count).should == "その２（被害状況即報） / 火災発生 / その他（件）"
      DisasterDamage.human_attribute_name(:field_public_educational_buildings_losses_amount).should == "その２（被害状況即報） / 公立文教施設（千円）"
      DisasterDamage.human_attribute_name(:field_agriculture_forestry_and_fisheries_buildings_losses_amount).should == "その２（被害状況即報） / 農林水産業施設（千円）"
      DisasterDamage.human_attribute_name(:field_public_civil_buildings_losses_amount).should == "その２（被害状況即報） / 公立土木施設（千円）"
      DisasterDamage.human_attribute_name(:field_other_public_buildings_losses_amount).should == "その２（被害状況即報） / その他の公共施設（千円）"
      DisasterDamage.human_attribute_name(:field_damaged_public_buildings_municipalities_count).should == "その２（被害状況即報） / 公共施設被害市町村数（団体）"
      DisasterDamage.human_attribute_name(:field_agriculture_losses_amount).should == "その２（被害状況即報） / その他 / 農業被害（千円）"
      DisasterDamage.human_attribute_name(:field_forestry_losses_amount).should == "その２（被害状況即報） / その他 / 林業被害（千円）"
      DisasterDamage.human_attribute_name(:field_livestock_losses_amount).should == "その２（被害状況即報） / その他 / 畜産被害（千円）"
      DisasterDamage.human_attribute_name(:field_fisheries_losses_amount).should == "その２（被害状況即報） / その他 / 水産被害（千円）"
      DisasterDamage.human_attribute_name(:field_commerce_and_industry_losses_amount).should == "その２（被害状況即報） / その他 / 商工被害（千円）"
      DisasterDamage.human_attribute_name(:field_other_losses_amount).should == "その２（被害状況即報） / その他 / その他（千円）"
      DisasterDamage.human_attribute_name(:field_prefectural_antidisaster_headquarter_status).should == "その２（被害状況即報） / 災害対策本部等の設置状況 / 都道府県"
      DisasterDamage.human_attribute_name(:field_prefectural_antidisaster_headquarter_status_at).should == "その２（被害状況即報） / 災害対策本部等の設置状況 / 都道府県 / 設置状況日時"
      DisasterDamage.human_attribute_name(:field_municipal_antidisaster_headquarter_of).should == "その２（被害状況即報） / 災害対策本部等の設置状況 / 市町村 / 設置市町村"
      DisasterDamage.human_attribute_name(:field_municipal_antidisaster_headquarter_type).should == "その２（被害状況即報） / 災害対策本部等の設置状況 / 市町村 / 本部種別"
      DisasterDamage.human_attribute_name(:field_municipal_antidisaster_headquarter_status).should == "その２（被害状況即報） / 災害対策本部等の設置状況 / 市町村"
      DisasterDamage.human_attribute_name(:field_municipal_antidisaster_headquarter_status_at).should == "その２（被害状況即報） / 災害対策本部等の設置状況 / 市町村 / 設置状況日時"
      DisasterDamage.human_attribute_name(:field_disaster_relief_act_applied_of).should == "その２（被害状況即報） / 災害救助法適用市町村名"
      DisasterDamage.human_attribute_name(:field_disaster_relief_act_applied_at).should == "その２（被害状況即報） / 災害救助法適用市町村名 / 適用日時"
      DisasterDamage.human_attribute_name(:field_disaster_relief_act_applied_municipalities_count).should == "その２（被害状況即報） / 災害救助法適用市町村名 / 適用市町村数"
      DisasterDamage.human_attribute_name(:field_turnout_fire_station_firefighter_count).should == "その２（被害状況即報） / 消防職員出勤延人数（人）"
      DisasterDamage.human_attribute_name(:field_turnout_fire_company_firefighter_count).should == "その２（被害状況即報） / 消防団員出勤延人数（人）"
      DisasterDamage.human_attribute_name(:field_note_disaster_occurred_location).should == "その２（被害状況即報） / 備考 / 災害発生場所"
      DisasterDamage.human_attribute_name(:field_note_disaster_occurred_date).should == "その２（被害状況即報） / 備考 / 災害発生年月日"
      DisasterDamage.human_attribute_name(:field_note_disaster_type_outline).should == "その２（被害状況即報） / 備考 / 災害の種類概況"
      DisasterDamage.human_attribute_name(:field_note_fire_services).should == "その２（被害状況即報） / 備考 / 応急対策の状況 / 消防、水防、救急・救助等消防機関の活動状況"
      DisasterDamage.human_attribute_name(:field_note_evacuation_advisories).should == "その２（被害状況即報） / 備考 / 応急対策の状況 / 避難の勧告・指示の状況"
      DisasterDamage.human_attribute_name(:field_note_shelters).should == "その２（被害状況即報） / 備考 / 応急対策の状況 / 避難所の設置状況"
      DisasterDamage.human_attribute_name(:field_note_other_local_government).should == "その２（被害状況即報） / 備考 / 応急対策の状況 / 他の地方公共団体への応援要請、応援活動の状況"
      DisasterDamage.human_attribute_name(:field_note_self_defence_force).should == "その２（被害状況即報） / 備考 / 応急対策の状況 / 自衛隊の派遣要請、出勤状況"
      DisasterDamage.human_attribute_name(:field_note_volunteer).should == "その２（被害状況即報） / 備考 / 応急対策の状況 / 災害ボランティアの活動状況"
      DisasterDamage.human_attribute_name(:field_disaster_occurred_date).should == "その１（災害概況即報） / 災害の概況 / 発生日時（年月日）"
      DisasterDamage.human_attribute_name(:field_disaster_occurred_hm).should == "その１（災害概況即報） / 災害の概況 / 発生日時（時分）"
      DisasterDamage.human_attribute_name(:field_general_prefectural_antidisaster_headquarter_status_date).should == "その１（災害概況即報） / 応急対策の状況 / 災害対策本部等の設置状況 / （都道府県） / 設置状況日時（年月日）"
      DisasterDamage.human_attribute_name(:field_general_prefectural_antidisaster_headquarter_status_hm).should == "その１（災害概況即報） / 応急対策の状況 / 災害対策本部等の設置状況 / （都道府県） / 設置状況日時（時分）"
      DisasterDamage.human_attribute_name(:field_general_municipal_antidisaster_headquarter_status_date).should == "その１（災害概況即報） / 応急対策の状況 / 災害対策本部等の設置状況 / （市町村） / 設置状況日時（年月日）"
      DisasterDamage.human_attribute_name(:field_general_municipal_antidisaster_headquarter_status_hm).should == "その１（災害概況即報） / 応急対策の状況 / 災害対策本部等の設置状況 / （市町村） / 設置状況日時（時分）"
      DisasterDamage.human_attribute_name(:field_prefectural_antidisaster_headquarter_status_date).should == "その２（被害状況即報） / 災害対策本部等の設置状況 / 都道府県 / 設置状況日時（年月日）"
      DisasterDamage.human_attribute_name(:field_prefectural_antidisaster_headquarter_status_hm).should == "その２（被害状況即報） / 災害対策本部等の設置状況 / 都道府県 / 設置状況日時（時分）"
      DisasterDamage.human_attribute_name(:field_municipal_antidisaster_headquarter_status_date).should == "その２（被害状況即報） / 災害対策本部等の設置状況 / 市町村 / 設置状況日時（年月日）"
      DisasterDamage.human_attribute_name(:field_municipal_antidisaster_headquarter_status_hm).should == "その２（被害状況即報） / 災害対策本部等の設置状況 / 市町村 / 設置状況日時（時分）"
      DisasterDamage.human_attribute_name(:field_disaster_relief_act_applied_date).should == "その２（被害状況即報） / 災害救助法適用市町村名 / 適用日時（年月日）"
      DisasterDamage.human_attribute_name(:field_disaster_relief_act_applied_hm).should == "その２（被害状況即報） / 災害救助法適用市町村名 / 適用日時（時分）"
    end
  end



  describe "#create_issues" do
    before do
      @create_general_damage_situation_issue_ret = "create_general_damage_situation_issue"
      @create_antidisaster_headquarter_issue_ret = "create_antidisaster_headquarter_issue"
      @create_damage_infomation_issue_ret        = "create_damage_infomation_issue"
    end
    describe "tracker_ids 17" do
      before do
        DisasterDamage.should_receive(:create_general_damage_situation_issue).with(@project).and_return(@create_general_damage_situation_issue_ret)
      end
      it "call create_general_damage_situation_issue" do
        issues = DisasterDamage.create_issues(@project, ["17"])
        
        issues.should == [@create_general_damage_situation_issue_ret]
      end
    end
    describe "tracker_ids 16" do
      before do
        DisasterDamage.should_receive(:create_antidisaster_headquarter_issue).with(@project).and_return(@create_antidisaster_headquarter_issue_ret)
      end
      it "call create_antidisaster_headquarter_issue" do
        issues = DisasterDamage.create_issues(@project, ["16"])
        
        issues.should == [@create_antidisaster_headquarter_issue_ret]
      end
    end
    describe "tracker_ids 18" do
      before do
        DisasterDamage.should_receive(:create_damage_infomation_issue).with(@project).and_return(@create_damage_infomation_issue_ret)
      end
      it "call create_damage_infomation_issue" do
        issues = DisasterDamage.create_issues(@project, ["18"])
        
        issues.should == [@create_damage_infomation_issue_ret]
      end
    end
  end


  describe "#create_general_damage_situation_issue" do
    before do
    end
    it "return new issue" do
      @disaster_damage.save
      @issue = DisasterDamage.create_general_damage_situation_issue(@project)
      
      @issue.tracker_id.should == 17
      @issue.project_id.should == @project.id
      @issue.subject.should =~ /^災害概況即報 (19|20)[0-9]{2}\/(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01]) (0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])$/
      @issue.author_id.should == User.find_by_type("AnonymousUser").id
      
      doc = Nokogiri::XML(@issue.xml_body)
      dd_key = "_災害概況即報 > "
      doc.css(dd_key+"災害識別情報").first.text.should      ==  @project.disaster_code.to_s
      doc.css(dd_key+"災害名").first.text.should            ==  @project.name.to_s
      doc.css(dd_key+"報告番号").first.text.should          ==  ""
      
      doc.css(dd_key+"報告日時 > 日付 > 年").first.text.should == ""
      doc.css(dd_key+"報告日時 > 日付 > 月").first.text.should == ""
      doc.css(dd_key+"報告日時 > 日付 > 日").first.text.should == ""
      doc.css(dd_key+"報告日時 > 時").first.text.should == ""
      doc.css(dd_key+"報告日時 > 分").first.text.should == ""
      doc.css(dd_key+"報告日時 > 秒").first.text.should == ""
      
      doc.css(dd_key+"都道府県").first.text.should          ==  ""
      doc.css(dd_key+"市町村_消防本部名").first.text.should ==  ""
      
      doc.css(dd_key+"報告者名 > 職員番号").first.text.should     == ""
      doc.css(dd_key+"報告者名 > 氏名 > 外字氏名").first.text.should     == ""
      doc.css(dd_key+"報告者名 > 氏名 > 内字氏名").first.text.should     == ""
      doc.css(dd_key+"報告者名 > 氏名 > フリガナ").first.text.should     == ""
      doc.css(dd_key+"報告者名 > 職員別名称 > 外字氏名").first.text.should     == ""
      doc.css(dd_key+"報告者名 > 職員別名称 > 内字氏名").first.text.should     == ""
      doc.css(dd_key+"報告者名 > 職員別名称 > フリガナ").first.text.should     == ""
      doc.css(dd_key+"外字発生場所").first.text.should     == ""
      doc.css(dd_key+"内字発生場所").first.text.should     == @disaster_damage.disaster_occurred_location.to_s
      
      doc.css(dd_key+"発生日時 > 日付 > 年").first.text.should == @disaster_damage.disaster_occurred_at.try(:year).to_s
      doc.css(dd_key+"発生日時 > 日付 > 月").first.text.should == @disaster_damage.disaster_occurred_at.try(:month).to_s
      doc.css(dd_key+"発生日時 > 日付 > 日").first.text.should == @disaster_damage.disaster_occurred_at.try(:day).to_s
      doc.css(dd_key+"発生日時 > 時").first.text.should == @disaster_damage.disaster_occurred_at.try(:hour).to_s
      doc.css(dd_key+"発生日時 > 分").first.text.should == @disaster_damage.disaster_occurred_at.try(:min).to_s
      doc.css(dd_key+"発生日時 > 秒").first.text.should == @disaster_damage.disaster_occurred_at.try(:sec).to_s
      
      doc.css(dd_key+"災害の概況").first.text.should     == @disaster_damage.general_disaster_situation.to_s
      
      doc.css(dd_key+"死傷者 > 死者").first.text.should     == @disaster_damage.general_dead_count.to_s
      doc.css(dd_key+"死傷者 > 不明").first.text.should     == @disaster_damage.general_missing_count.to_s
      doc.css(dd_key+"死傷者 > 負傷者").first.text.should   == @disaster_damage.general_injured_count.to_s
      doc.css(dd_key+"死傷者 > 計").first.text.should       == (@disaster_damage.general_dead_count + @disaster_damage.general_missing_count + @disaster_damage.general_injured_count).to_s
      
      doc.css(dd_key+"住家 > 全壊_棟").first.text.should     == @disaster_damage.general_complete_collapse_houses_count.to_s
      doc.css(dd_key+"住家 > 一部破損_棟").first.text.should == @disaster_damage.general_partial_damage_houses_count.to_s
      doc.css(dd_key+"住家 > 半壊_棟").first.text.should     == @disaster_damage.general_half_collapse_houses_count.to_s
      doc.css(dd_key+"住家 > 床上浸水_棟").first.text.should == @disaster_damage.general_inundation_above_floor_level_houses_count.to_s
      
      doc.css(dd_key+"被害の状況").first.text.should     == @disaster_damage.general_damages_status.to_s
      
      doc.css(dd_key+"災害対策本部等設置状況_都道府県 > 設置状況").first.text.should == @disaster_damage.general_prefectural_antidisaster_headquarter_status.to_s
      doc.css(dd_key+"災害対策本部等設置状況_都道府県 > 設置状況日時 > 日付 > 年").first.text.should == @disaster_damage.general_prefectural_antidisaster_headquarter_status_at.try(:year).to_s
      doc.css(dd_key+"災害対策本部等設置状況_都道府県 > 設置状況日時 > 日付 > 月").first.text.should == @disaster_damage.general_prefectural_antidisaster_headquarter_status_at.try(:month).to_s
      doc.css(dd_key+"災害対策本部等設置状況_都道府県 > 設置状況日時 > 日付 > 日").first.text.should == @disaster_damage.general_prefectural_antidisaster_headquarter_status_at.try(:day).to_s
      doc.css(dd_key+"災害対策本部等設置状況_都道府県 > 設置状況日時 > 時").first.text.should == @disaster_damage.general_prefectural_antidisaster_headquarter_status_at.try(:hour).to_s
      doc.css(dd_key+"災害対策本部等設置状況_都道府県 > 設置状況日時 > 分").first.text.should == @disaster_damage.general_prefectural_antidisaster_headquarter_status_at.try(:min).to_s
      doc.css(dd_key+"災害対策本部等設置状況_都道府県 > 設置状況日時 > 秒").first.text.should == @disaster_damage.general_prefectural_antidisaster_headquarter_status_at.try(:sec).to_s
      
      doc.css(dd_key+"災害対策本部等設置状況_市町村 > 災害対策本部等設置市町村").first.text.should == @disaster_damage.general_municipal_antidisaster_headquarter_of.to_s
      doc.css(dd_key+"災害対策本部等設置状況_市町村 > 設置状況").first.text.should == @disaster_damage.general_municipal_antidisaster_headquarter_status.to_s
      doc.css(dd_key+"災害対策本部等設置状況_市町村 > 設置状況日時 > 日付 > 年").first.text.should == @disaster_damage.general_municipal_antidisaster_headquarter_status_at.try(:year).to_s
      doc.css(dd_key+"災害対策本部等設置状況_市町村 > 設置状況日時 > 日付 > 月").first.text.should == @disaster_damage.general_municipal_antidisaster_headquarter_status_at.try(:month).to_s
      doc.css(dd_key+"災害対策本部等設置状況_市町村 > 設置状況日時 > 日付 > 日").first.text.should == @disaster_damage.general_municipal_antidisaster_headquarter_status_at.try(:day).to_s
      doc.css(dd_key+"災害対策本部等設置状況_市町村 > 設置状況日時 > 時").first.text.should == @disaster_damage.general_municipal_antidisaster_headquarter_status_at.try(:hour).to_s
      doc.css(dd_key+"災害対策本部等設置状況_市町村 > 設置状況日時 > 分").first.text.should == @disaster_damage.general_municipal_antidisaster_headquarter_status_at.try(:min).to_s
      doc.css(dd_key+"災害対策本部等設置状況_市町村 > 設置状況日時 > 秒").first.text.should == @disaster_damage.general_municipal_antidisaster_headquarter_status_at.try(:sec).to_s
      
      doc.css(dd_key+"応急対策の状況").first.text.should     == @disaster_damage.emergency_measures_status.to_s
    end
  end


  describe "#create_damage_infomation_issue" do
    describe "all value exist" do
      it "return new issue with all value" do
        @disaster_damage.save
        @issue = DisasterDamage.create_damage_infomation_issue(@project)
        
        @issue.tracker_id.should == 18
        @issue.project_id.should == @project.id
        @issue.subject.should =~ /^被害情報 (19|20)[0-9]{2}\/(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01]) (0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])$/
        @issue.author_id.should == User.find_by_type("AnonymousUser").id
        
        doc = Nokogiri::XML(@issue.xml_body)
        
        root_key = "DamageInformation > "
        doc.css(root_key+"Disaster > DisasterName").first.text.should == @project.name.to_s
        doc.css(root_key+"ComplementaryInfo").first.text.should == ""
        
        doc.css(root_key+"HumanDamages > HumanDamage[counterUnit='人'][humanDamageType='死者']").first.text.should         == @disaster_damage.dead_count.to_s
        doc.css(root_key+"HumanDamages > HumanDamage[counterUnit='人'][humanDamageType='行方不明者数']").first.text.should == @disaster_damage.missing_count.to_s
        doc.css(root_key+"HumanDamages > HumanDamage[counterUnit='人'][humanDamageType='負傷者_重傷']").first.text.should  == @disaster_damage.seriously_injured_count.to_s
        doc.css(root_key+"HumanDamages > HumanDamage[counterUnit='人'][humanDamageType='負傷者_軽傷']").first.text.should  == @disaster_damage.slightly_injured_count.to_s
        
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='棟'][houseDamageType='全壊']").first.text.should   == @disaster_damage.complete_collapse_houses_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='世帯'][houseDamageType='全壊']").first.text.should == @disaster_damage.complete_collapse_households_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='人'][houseDamageType='全壊']").first.text.should   == @disaster_damage.complete_collapse_people_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='棟'][houseDamageType='半壊']").first.text.should   == @disaster_damage.half_collapse_houses_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='世帯'][houseDamageType='半壊']").first.text.should == @disaster_damage.half_collapse_households_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='人'][houseDamageType='半壊']").first.text.should   == @disaster_damage.half_collapse_people_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='棟'][houseDamageType='一部破損']").first.text.should   == @disaster_damage.partial_damage_houses_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='世帯'][houseDamageType='一部破損']").first.text.should == @disaster_damage.partial_damage_households_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='人'][houseDamageType='一部破損']").first.text.should   == @disaster_damage.partial_damage_people_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='棟'][houseDamageType='床上浸水']").first.text.should   == @disaster_damage.inundation_above_floor_level_houses_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='世帯'][houseDamageType='床上浸水']").first.text.should == @disaster_damage.inundation_above_floor_level_households_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='人'][houseDamageType='床上浸水']").first.text.should   == @disaster_damage.inundation_above_floor_level_people_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='棟'][houseDamageType='床下浸水']").first.text.should   == @disaster_damage.inundation_under_floor_level_houses_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='世帯'][houseDamageType='床下浸水']").first.text.should == @disaster_damage.inundation_under_floor_level_households_count.to_s
        doc.css(root_key+"HouseDamages > HouseDamage[counterUnit='人'][houseDamageType='床下浸水']").first.text.should   == @disaster_damage.inundation_under_floor_level_people_count.to_s
        
        doc.css(root_key+"BuildingDamages > BuildingDamage[counterUnit='棟'][buildingDamageType='公共建物']").first.text.should == @disaster_damage.damaged_public_building_count.to_s
        doc.css(root_key+"BuildingDamages > BuildingDamage[counterUnit='棟'][buildingDamageType='その他']").first.text.should   == @disaster_damage.damaged_other_building_count.to_s
        
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='ha'][otherDamageType='田_流出埋没']").first.text.should    == @disaster_damage.buried_or_washed_out_rice_field_ha.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='ha'][otherDamageType='田_冠水']").first.text.should        == @disaster_damage.under_water_rice_field_ha.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='ha'][otherDamageType='畑_流出埋没']").first.text.should    == @disaster_damage.buried_or_washed_out_upland_field_ha.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='ha'][otherDamageType='畑_冠水']").first.text.should        == @disaster_damage.under_water_upland_field_ha.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='箇所'][otherDamageType='文教施設']").first.text.should     == @disaster_damage.damaged_educational_facilities_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='箇所'][otherDamageType='病院']").first.text.should         == @disaster_damage.damaged_hospitals_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='箇所'][otherDamageType='道路']").first.text.should         == @disaster_damage.damaged_roads_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='箇所'][otherDamageType='橋りょう']").first.text.should     == @disaster_damage.damaged_bridges_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='箇所'][otherDamageType='河川']").first.text.should         == @disaster_damage.damaged_rivers_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='箇所'][otherDamageType='港湾']").first.text.should         == @disaster_damage.damaged_harbors_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='箇所'][otherDamageType='砂防']").first.text.should         == @disaster_damage.damaged_sand_control_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='箇所'][otherDamageType='清掃施設']").first.text.should     == @disaster_damage.damaged_cleaning_facilities_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='箇所'][otherDamageType='崖くずれ']").first.text.should     == @disaster_damage.landslides_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='箇所'][otherDamageType='鉄道不通']").first.text.should     == @disaster_damage.closed_lines_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='隻'][otherDamageType='被害船舶']").first.text.should       == @disaster_damage.damaged_ships_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='戸'][otherDamageType='水道']").first.text.should           == @disaster_damage.water_failure_houses_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='回線'][otherDamageType='電話']").first.text.should         == @disaster_damage.dead_telephone_lines_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='戸'][otherDamageType='電気']").first.text.should           == @disaster_damage.blackout_houses_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='戸'][otherDamageType='ガス']").first.text.should           == @disaster_damage.gas_supply_stopped_houses_count.to_s
        doc.css(root_key+"OtherDamages > OtherDamage[counterUnit='箇所'][otherDamageType='ブロック塀等']").first.text.should == @disaster_damage.damaged_concrete_block_walls_count.to_s
        
        doc.css(root_key+"Sufferers > Sufferer[counterUnit='世帯'][suffererDamageType='り災世帯数']").first.text.should == @disaster_damage.sufferer_houses_count.to_s
        doc.css(root_key+"Sufferers > Sufferer[counterUnit='人'][suffererDamageType='り災者数']").first.text.should     == @disaster_damage.sufferer_people_count.to_s
        
        doc.css(root_key+"FireDamages > FireDamage[counterUnit='件'][fireDamageType='建物']").first.text.should   == @disaster_damage.fire_occurred_buildings_count.to_s
        doc.css(root_key+"FireDamages > FireDamage[counterUnit='件'][fireDamageType='危険物']").first.text.should == @disaster_damage.fire_occurred_dangerous_substances_count.to_s
        doc.css(root_key+"FireDamages > FireDamage[counterUnit='件'][fireDamageType='その他']").first.text.should == @disaster_damage.fire_occurred_others_count.to_s
        
        doc.css(root_key+"Losses > FacilitiesLosses > Loss[counterUnit='千円'][lossesDamageType='公共文教施設']").first.text.should   == @disaster_damage.public_educational_buildings_losses_amount.to_s
        doc.css(root_key+"Losses > FacilitiesLosses > Loss[counterUnit='千円'][lossesDamageType='農林水産業施設']").first.text.should == @disaster_damage.agriculture_forestry_and_fisheries_buildings_losses_amount.to_s
        doc.css(root_key+"Losses > FacilitiesLosses > Loss[counterUnit='千円'][lossesDamageType='公共土木施設']").first.text.should   == @disaster_damage.public_civil_buildings_losses_amount.to_s
        doc.css(root_key+"Losses > FacilitiesLosses > TotalLosses[currencyUnit='千円']").first.text.should == (@disaster_damage.public_educational_buildings_losses_amount +
                                                                                                              @disaster_damage.agriculture_forestry_and_fisheries_buildings_losses_amount +
                                                                                                              @disaster_damage.public_civil_buildings_losses_amount
                                                                                                             ).to_s
        doc.css(root_key+"Losses > OtherLosses > Loss[counterUnit='千円'][lossesDamageType='農業被害']").first.text.should   == @disaster_damage.agriculture_losses_amount.to_s
        doc.css(root_key+"Losses > OtherLosses > Loss[counterUnit='千円'][lossesDamageType='林業被害']").first.text.should   == @disaster_damage.forestry_losses_amount.to_s
        doc.css(root_key+"Losses > OtherLosses > Loss[counterUnit='千円'][lossesDamageType='畜産被害']").first.text.should   == @disaster_damage.livestock_losses_amount.to_s
        doc.css(root_key+"Losses > OtherLosses > Loss[counterUnit='千円'][lossesDamageType='水産被害']").first.text.should   == @disaster_damage.fisheries_losses_amount.to_s
        doc.css(root_key+"Losses > OtherLosses > Loss[counterUnit='千円'][lossesDamageType='商工被害']").first.text.should   == @disaster_damage.commerce_and_industry_losses_amount.to_s
        doc.css(root_key+"Losses > OtherLosses > Loss[counterUnit='千円'][lossesDamageType='その他']").first.text.should   == @disaster_damage.other_losses_amount.to_s
        
        doc.css(root_key+"Losses > TotalLosses[currencyUnit='千円']").first.text.should == (@disaster_damage.public_educational_buildings_losses_amount +
                                                                                                         @disaster_damage.agriculture_forestry_and_fisheries_buildings_losses_amount +
                                                                                                         @disaster_damage.public_civil_buildings_losses_amount +
                                                                                                         @disaster_damage.agriculture_losses_amount +
                                                                                                         @disaster_damage.forestry_losses_amount +
                                                                                                         @disaster_damage.livestock_losses_amount +
                                                                                                         @disaster_damage.fisheries_losses_amount +
                                                                                                         @disaster_damage.commerce_and_industry_losses_amount +
                                                                                                         @disaster_damage.other_losses_amount
                                                                                                        ).to_s
        
        doc.css(root_key+"Firefighter > TurnoutFireStation").first.text.should == @disaster_damage.turnout_fire_station_firefighter_count.to_s
        doc.css(root_key+"Firefighter > TurnoutFireCompany").first.text.should == @disaster_damage.turnout_fire_company_firefighter_count.to_s
      end
    end
    describe "all value not exist" do
      it "return new issue without HumanDamages, HouseDamages etc..." do
        @disaster_damage.dead_count = nil
        @disaster_damage.missing_count = nil
        @disaster_damage.seriously_injured_count = nil
        @disaster_damage.slightly_injured_count = nil
        
        @disaster_damage.complete_collapse_houses_count = nil
        @disaster_damage.complete_collapse_households_count = nil
        @disaster_damage.complete_collapse_people_count = nil
        @disaster_damage.half_collapse_houses_count = nil
        @disaster_damage.half_collapse_households_count = nil
        @disaster_damage.half_collapse_people_count = nil
        @disaster_damage.partial_damage_houses_count = nil
        @disaster_damage.partial_damage_households_count = nil
        @disaster_damage.partial_damage_people_count = nil
        @disaster_damage.inundation_above_floor_level_houses_count = nil
        @disaster_damage.inundation_above_floor_level_households_count = nil
        @disaster_damage.inundation_above_floor_level_people_count = nil
        @disaster_damage.inundation_under_floor_level_houses_count = nil
        @disaster_damage.inundation_under_floor_level_households_count = nil
        @disaster_damage.inundation_under_floor_level_people_count = nil
        
        @disaster_damage.damaged_public_building_count = nil
        @disaster_damage.damaged_other_building_count = nil
        
        @disaster_damage.buried_or_washed_out_rice_field_ha = nil
        @disaster_damage.under_water_rice_field_ha = nil
        @disaster_damage.buried_or_washed_out_upland_field_ha = nil
        @disaster_damage.under_water_upland_field_ha = nil
        @disaster_damage.damaged_educational_facilities_count = nil
        @disaster_damage.damaged_hospitals_count = nil
        @disaster_damage.damaged_roads_count = nil
        @disaster_damage.damaged_bridges_count = nil
        @disaster_damage.damaged_rivers_count = nil
        @disaster_damage.damaged_harbors_count = nil
        @disaster_damage.damaged_sand_control_count = nil
        @disaster_damage.damaged_cleaning_facilities_count = nil
        @disaster_damage.landslides_count = nil
        @disaster_damage.closed_lines_count = nil
        @disaster_damage.damaged_ships_count = nil
        @disaster_damage.water_failure_houses_count = nil
        @disaster_damage.dead_telephone_lines_count = nil
        @disaster_damage.blackout_houses_count = nil
        @disaster_damage.gas_supply_stopped_houses_count = nil
        @disaster_damage.damaged_concrete_block_walls_count = nil
        
        @disaster_damage.sufferer_houses_count = nil
        @disaster_damage.sufferer_people_count = nil
        
        @disaster_damage.fire_occurred_buildings_count = nil
        @disaster_damage.fire_occurred_dangerous_substances_count = nil
        @disaster_damage.fire_occurred_others_count = nil
        
        @disaster_damage.public_educational_buildings_losses_amount = nil
        @disaster_damage.agriculture_forestry_and_fisheries_buildings_losses_amount = nil
        @disaster_damage.public_civil_buildings_losses_amount = nil
        @disaster_damage.agriculture_losses_amount = nil
        @disaster_damage.forestry_losses_amount = nil
        @disaster_damage.livestock_losses_amount = nil
        @disaster_damage.fisheries_losses_amount = nil
        @disaster_damage.commerce_and_industry_losses_amount = nil
        @disaster_damage.other_losses_amount = nil
        
        @disaster_damage.turnout_fire_station_firefighter_count = nil
        @disaster_damage.turnout_fire_company_firefighter_count = nil


        @disaster_damage.save
        @issue = DisasterDamage.create_damage_infomation_issue(@project)
        
        @issue.tracker_id.should == 18
        @issue.project_id.should == @project.id
        @issue.subject.should =~ /^被害情報 (19|20)[0-9]{2}\/(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01]) (0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])$/
        @issue.author_id.should == User.find_by_type("AnonymousUser").id
        
        doc = Nokogiri::XML(@issue.xml_body)
        
        root_key = "DamageInformation > "
        doc.css(root_key+"Disaster > DisasterName").first.text.should == @project.name.to_s
        doc.css(root_key+"ComplementaryInfo").first.text.should == ""
        
        doc.css(root_key+"HumanDamages").first.should    be_blank
        doc.css(root_key+"HouseDamages").first.should    be_blank
        doc.css(root_key+"BuildingDamages").first.should be_blank
        doc.css(root_key+"OtherDamages").first.should    be_blank
        doc.css(root_key+"Sufferers").first.should       be_blank
        doc.css(root_key+"FireDamages").first.should     be_blank
        doc.css(root_key+"Losses").first.should          be_blank
        doc.css(root_key+"Firefighter").first.should     be_blank
      end
    end
  end
  
  
  describe "#create_antidisaster_headquarter_issue" do
    describe "all value exist" do
      it "return new issue" do
        @disaster_damage.save
        @issue = DisasterDamage.create_antidisaster_headquarter_issue(@project)
        
        @issue.tracker_id.should == 16
        @issue.project_id.should == @project.id
        @issue.subject.should =~ /^災害対策本部設置状況 (19|20)[0-9]{2}\/(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01]) (0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])$/
        @issue.author_id.should == User.find_by_type("AnonymousUser").id
        
        doc = Nokogiri::XML(@issue.xml_body)
        
        root_key = "AntidisasterHeadquarter > "
        doc.css(root_key+"Disaster > DisasterName").first.text.should == @project.name.to_s
        
        doc.css(root_key+"Type").first.text.should     == CONST["municipal_antidisaster_headquarter_type"]["#{@disaster_damage.municipal_antidisaster_headquarter_type}"].to_s
        doc.css(root_key+"Status").first.text.should   == CONST["municipal_antidisaster_headquarter_status"]["#{@disaster_damage.municipal_antidisaster_headquarter_status}"].to_s
        doc.css(root_key+"DateTime").first.text.should == @disaster_damage.municipal_antidisaster_headquarter_status_at.xmlschema.to_s
        
      end
    end
  end
  
  
  describe "#int_sum" do
    describe "args present" do
      it "return sum args" do
        DisasterDamage.int_sum(1,2,3,4,5,6,7,8,9).should == 1+2+3+4+5+6+7+8+9
      end
    end
    describe "args blank" do
      it "return nil" do
        DisasterDamage.int_sum().should be_nil
      end
    end
  end
  
end

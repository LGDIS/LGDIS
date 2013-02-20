# -*- coding:utf-8 -*-
FactoryGirl.define do
  factory :disaster_damage1, :class => "DisasterDamage" do
    disaster_occurred_location "石巻市"
    #disaster_occurred_at
    #general_disaster_situation
    general_dead_count 1
    general_missing_count 1
    general_injured_count 1
    general_complete_collapse_houses_count 1
    general_partial_damage_houses_count 1
    general_half_collapse_houses_count 1
    general_inundation_above_floor_level_houses_count 1
    #general_damages_status
    #general_prefectural_antidisaster_headquarter_status
    #general_prefectural_antidisaster_headquarter_status_at
    #general_municipal_antidisaster_headquarter_of
    #general_municipal_antidisaster_headquarter_status
    #general_municipal_antidisaster_headquarter_status_at
    #emergency_measures_status
    dead_count 1
    missing_count 1
    seriously_injured_count 1
    slightly_injured_count 1
    complete_collapse_houses_count 1
    complete_collapse_households_count 1
    complete_collapse_people_count 1
    half_collapse_houses_count 1
    half_collapse_households_count 1
    half_collapse_people_count 1
    partial_damage_houses_count 1
    partial_damage_households_count 1
    partial_damage_people_count 1
    inundation_above_floor_level_houses_count 1
    inundation_above_floor_level_households_count 1
    inundation_above_floor_level_people_count 1
    inundation_under_floor_level_houses_count 1
    inundation_under_floor_level_households_count 1
    inundation_under_floor_level_people_count 1
    damaged_public_building_count 1
    damaged_other_building_count 1
    buried_or_washed_out_rice_field_ha 1
    under_water_rice_field_ha 1
    buried_or_washed_out_upland_field_ha 1
    under_water_upland_field_ha 1
    damaged_educational_facilities_count 1
    damaged_hospitals_count 1
    damaged_roads_count 1
    damaged_bridges_count 1
    damaged_rivers_count 1
    damaged_harbors_count 1
    damaged_sand_control_count 1
    damaged_cleaning_facilities_count 1
    landslides_count 1
    closed_lines_count 1
    damaged_ships_count 1
    water_failure_houses_count 1
    dead_telephone_lines_count 1
    blackout_houses_count 1
    gas_supply_stopped_houses_count 1
    damaged_concrete_block_walls_count 1
    sufferer_houses_count 1
    sufferer_people_count 1
    fire_occurred_buildings_count 1
    fire_occurred_dangerous_substances_count 1
    fire_occurred_others_count 1
    public_educational_buildings_losses_amount 1
    agriculture_forestry_and_fisheries_buildings_losses_amount 1
    public_civil_buildings_losses_amount 1
    other_public_buildings_losses_amount 1
    damaged_public_buildings_municipalities_count 1
    agriculture_losses_amount 1
    forestry_losses_amount 1
    livestock_losses_amount 1
    fisheries_losses_amount 1
    commerce_and_industry_losses_amount 1
    other_losses_amount 1
    #prefectural_antidisaster_headquarter_status
    #prefectural_antidisaster_headquarter_status_at
    #municipal_antidisaster_headquarter_of
    #municipal_antidisaster_headquarter_type
    #municipal_antidisaster_headquarter_status
    #municipal_antidisaster_headquarter_status_at
    #disaster_relief_act_applied_of
    #disaster_relief_act_applied_at
    disaster_relief_act_applied_municipalities_count 1
    turnout_fire_station_firefighter_count 1
    turnout_fire_company_firefighter_count 1
    #note_disaster_occurred_location
    #note_disaster_occurred_date
    #note_disaster_type_outline
    #note_fire_services
    #note_evacuation_advisories
    #note_shelters
    #note_other_local_government
    #note_self_defence_force
    #note_volunteer

  end
end


# encoding: utf-8
class DisasterDamage < ActiveRecord::Base
  unloadable
  
  # 正の整数チェック用オプションハッシュ値
  POSITIVE_INTEGER = {:only_integer => true,
                      :greater_than_or_equal_to => 0,
                      :less_than_or_equal_to => 2147483647,
                      :allow_blank => true}.freeze
  
  # コンスタント存在チェック用
  CONST = Constant::hash_for_table(self.table_name).freeze
  
  validates :disaster_occurred_location,
                :length => {:maximum => 100}
  # validates :disaster_occurred_at
  validates :disaster_occurred_date,
                :custom_format => {:type => :date}
  validates :disaster_occurred_date, :presence => true, :unless => "disaster_occurred_hm.blank?"
  validates :disaster_occurred_hm,
                :custom_format => {:type => :time}
  validates :disaster_occurred_hm, :presence => true, :unless => "disaster_occurred_date.blank?"
  validates :general_disaster_situation,
                :length => {:maximum => 4000}
  validates :general_dead_count,
                :numericality => POSITIVE_INTEGER
  validates :general_missing_count,
                :numericality => POSITIVE_INTEGER
  validates :general_injured_count,
                :numericality => POSITIVE_INTEGER
  validates :general_complete_collapse_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :general_partial_damage_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :general_half_collapse_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :general_inundation_above_floor_level_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :general_damages_status,
                :length => {:maximum => 4000}
  validates :general_prefectural_antidisaster_headquarter_status,
                :length => {:maximum => 4000}
  # validates :general_prefectural_antidisaster_headquarter_status_at
  validates :general_prefectural_antidisaster_headquarter_status_date,
                :custom_format => {:type => :date}
  validates :general_prefectural_antidisaster_headquarter_status_date, :presence => true, :unless => "general_prefectural_antidisaster_headquarter_status_hm.blank?"
  validates :general_prefectural_antidisaster_headquarter_status_hm,
                :custom_format => {:type => :time}
  validates :general_prefectural_antidisaster_headquarter_status_hm, :presence => true, :unless => "general_prefectural_antidisaster_headquarter_status_date.blank?"
  validates :general_municipal_antidisaster_headquarter_of,
                :length => {:maximum => 12}
  validates :general_municipal_antidisaster_headquarter_status,
                :length => {:maximum => 4000}
  # validates :general_municipal_antidisaster_headquarter_status_at
  validates :general_municipal_antidisaster_headquarter_status_date,
                :custom_format => {:type => :date}
  validates :general_municipal_antidisaster_headquarter_status_date, :presence => true, :unless => "general_municipal_antidisaster_headquarter_status_hm.blank?"
  validates :general_municipal_antidisaster_headquarter_status_hm,
                :custom_format => {:type => :time}
  validates :general_municipal_antidisaster_headquarter_status_hm, :presence => true, :unless => "general_municipal_antidisaster_headquarter_status_date.blank?"
  validates :emergency_measures_status,
                :length => {:maximum => 4000}
  validates :dead_count,
                :numericality => POSITIVE_INTEGER
  validates :missing_count,
                :numericality => POSITIVE_INTEGER
  validates :seriously_injured_count,
                :numericality => POSITIVE_INTEGER
  validates :slightly_injured_count,
                :numericality => POSITIVE_INTEGER
  validates :complete_collapse_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :complete_collapse_households_count,
                :numericality => POSITIVE_INTEGER
  validates :complete_collapse_people_count,
                :numericality => POSITIVE_INTEGER
  validates :half_collapse_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :half_collapse_households_count,
                :numericality => POSITIVE_INTEGER
  validates :half_collapse_people_count,
                :numericality => POSITIVE_INTEGER
  validates :partial_damage_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :partial_damage_households_count,
                :numericality => POSITIVE_INTEGER
  validates :partial_damage_people_count,
                :numericality => POSITIVE_INTEGER
  validates :inundation_above_floor_level_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :inundation_above_floor_level_households_count,
                :numericality => POSITIVE_INTEGER
  validates :inundation_above_floor_level_people_count,
                :numericality => POSITIVE_INTEGER
  validates :inundation_under_floor_level_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :inundation_under_floor_level_households_count,
                :numericality => POSITIVE_INTEGER
  validates :inundation_under_floor_level_people_count,
                :numericality => POSITIVE_INTEGER
  validates :damaged_public_building_count,
                :numericality => POSITIVE_INTEGER
  validates :damaged_other_building_count,
                :numericality => POSITIVE_INTEGER
  validates :buried_or_washed_out_rice_field_ha,
                :numericality => POSITIVE_INTEGER
  validates :under_water_rice_field_ha,
                :numericality => POSITIVE_INTEGER
  validates :buried_or_washed_out_upland_field_ha,
                :numericality => POSITIVE_INTEGER
  validates :under_water_upland_field_ha,
                :numericality => POSITIVE_INTEGER
  validates :damaged_educational_facilities_count,
                :numericality => POSITIVE_INTEGER
  validates :damaged_hospitals_count,
                :numericality => POSITIVE_INTEGER
  validates :damaged_roads_count,
                :numericality => POSITIVE_INTEGER
  validates :damaged_bridges_count,
                :numericality => POSITIVE_INTEGER
  validates :damaged_rivers_count,
                :numericality => POSITIVE_INTEGER
  validates :damaged_harbors_count,
                :numericality => POSITIVE_INTEGER
  validates :damaged_sand_control_count,
                :numericality => POSITIVE_INTEGER
  validates :damaged_cleaning_facilities_count,
                :numericality => POSITIVE_INTEGER
  validates :landslides_count,
                :numericality => POSITIVE_INTEGER
  validates :closed_lines_count,
                :numericality => POSITIVE_INTEGER
  validates :damaged_ships_count,
                :numericality => POSITIVE_INTEGER
  validates :water_failure_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :dead_telephone_lines_count,
                :numericality => POSITIVE_INTEGER
  validates :blackout_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :gas_supply_stopped_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :damaged_concrete_block_walls_count,
                :numericality => POSITIVE_INTEGER
  validates :sufferer_houses_count,
                :numericality => POSITIVE_INTEGER
  validates :sufferer_people_count,
                :numericality => POSITIVE_INTEGER
  validates :fire_occurred_buildings_count,
                :numericality => POSITIVE_INTEGER
  validates :fire_occurred_dangerous_substances_count,
                :numericality => POSITIVE_INTEGER
  validates :fire_occurred_others_count,
                :numericality => POSITIVE_INTEGER
  validates :public_educational_buildings_losses_amount,
                :numericality => POSITIVE_INTEGER
  validates :agriculture_forestry_and_fisheries_buildings_losses_amount,
                :numericality => POSITIVE_INTEGER
  validates :public_civil_buildings_losses_amount,
                :numericality => POSITIVE_INTEGER
  validates :other_public_buildings_losses_amount,
                :numericality => POSITIVE_INTEGER
  validates :damaged_public_buildings_municipalities_count,
                :numericality => POSITIVE_INTEGER
  validates :agriculture_losses_amount,
                :numericality => POSITIVE_INTEGER
  validates :forestry_losses_amount,
                :numericality => POSITIVE_INTEGER
  validates :livestock_losses_amount,
                :numericality => POSITIVE_INTEGER
  validates :fisheries_losses_amount,
                :numericality => POSITIVE_INTEGER
  validates :commerce_and_industry_losses_amount,
                :numericality => POSITIVE_INTEGER
  validates :other_losses_amount,
                :numericality => POSITIVE_INTEGER
  validates :prefectural_antidisaster_headquarter_status,
                :length => {:maximum => 4000}
  # validates :prefectural_antidisaster_headquarter_status_at
  validates :prefectural_antidisaster_headquarter_status_date,
                :custom_format => {:type => :date}
  validates :prefectural_antidisaster_headquarter_status_date, :presence => true, :unless => "prefectural_antidisaster_headquarter_status_hm.blank?"
  validates :prefectural_antidisaster_headquarter_status_hm,
                :custom_format => {:type => :time}
  validates :prefectural_antidisaster_headquarter_status_hm, :presence => true, :unless => "prefectural_antidisaster_headquarter_status_date.blank?"
  validates :municipal_antidisaster_headquarter_of,
                :length => {:maximum => 12}
  validates :municipal_antidisaster_headquarter_type,
                :inclusion => {:in => CONST[:municipal_antidisaster_headquarter_type.to_s].keys, :allow_blank => true}
  validates :municipal_antidisaster_headquarter_status,
                :inclusion => {:in => CONST[:municipal_antidisaster_headquarter_status.to_s].keys, :allow_blank => true}
  # validates :municipal_antidisaster_headquarter_status_at
  validates :municipal_antidisaster_headquarter_status_date,
                :custom_format => {:type => :date}
  validates :municipal_antidisaster_headquarter_status_date, :presence => true, :unless => "municipal_antidisaster_headquarter_status_hm.blank?"
  validates :municipal_antidisaster_headquarter_status_hm,
                :custom_format => {:type => :time}
  validates :municipal_antidisaster_headquarter_status_hm, :presence => true, :unless => "municipal_antidisaster_headquarter_status_date.blank?"
  validates :disaster_relief_act_applied_of,
                :length => {:maximum => 12}
  # validates :disaster_relief_act_applied_at
  validates :disaster_relief_act_applied_date,
                :custom_format => {:type => :date}
  validates :disaster_relief_act_applied_date, :presence => true, :unless => "disaster_relief_act_applied_hm.blank?"
  validates :disaster_relief_act_applied_hm,
                :custom_format => {:type => :time}
  validates :disaster_relief_act_applied_hm, :presence => true, :unless => "disaster_relief_act_applied_date.blank?"
  validates :disaster_relief_act_applied_municipalities_count,
                :numericality => POSITIVE_INTEGER
  validates :turnout_fire_station_firefighter_count,
                :numericality => POSITIVE_INTEGER
  validates :turnout_fire_company_firefighter_count,
                :numericality => POSITIVE_INTEGER
  validates :note_disaster_occurred_location,
                :length => {:maximum => 100}
  validates :note_disaster_occurred_date,
                :length => {:maximum => 100}
  validates :note_disaster_type_outline,
                :length => {:maximum => 4000}
  validates :note_fire_services,
                :length => {:maximum => 4000}
  validates :note_evacuation_advisories,
                :length => {:maximum => 4000}
  validates :note_shelters,
                :length => {:maximum => 4000}
  validates :note_other_local_government,
                :length => {:maximum => 4000}
  validates :note_self_defence_force,
                :length => {:maximum => 4000}
  validates :note_volunteer,
                :length => {:maximum => 4000}
  
  # 属性のローカライズ名取得
  # validateエラー時のメッセージに使用されます。
  # "field_" + 属性名 でローカライズします。
  # モデル名の複数系をスコープに設定してローカライズできない場合は、スコープ無しのローカライズ結果を返却します。
  # ==== Args
  # _attr_ :: 属性名
  # _args_ :: args
  # ==== Return
  # 項目名
  # ==== Raise
  def self.human_attribute_name(attr, *args)
    begin
      localized = l("field_#{name.underscore.gsub('/', '_')}_#{attr}",
                    :scope => self.name.underscore.pluralize,
                    :default => ["field_#{attr}".to_sym, attr],
                    :raise => true)
    rescue
    end
    localized ||= l("field_#{name.underscore.gsub('/', '_')}_#{attr}",
                    :default => ["field_#{attr}".to_sym, attr])
  end
  
  # 日時フィールドに対して、日付、時刻フィールドに分割したアクセサを定義します。
  # 例) create_at ⇒ create_date, create_hm
  # ==== Args
  # _attrs_ :: attrs
  # ==== Return
  # ==== Raise
  def self.attr_accessor_separate_datetime(*attrs)
    attrs.each do |attr|
      prefix = attr.to_s.gsub("_at","")
      define_method("#{prefix}_date") do
        val = eval("@#{prefix}_date")
        base_value = eval("self.#{attr}")
        # timezoneの考慮が必要
        # see:Redmine::I18n#format_time
        zone = User.current.time_zone
        base_value &&= zone ? base_value.in_time_zone(zone) : (base_value.utc? ? base_value.localtime : base_value)
        base_value &&= base_value.to_date
        val || base_value
      end
      
      define_method("#{prefix}_date=") do |val|
        instance_variable_set("@#{prefix}_date", val)
        set_date_time_attr("#{attr}", val, eval("#{prefix}_hm"))
      end
      
      define_method("#{prefix}_hm") do
        val = eval("@#{prefix}_hm")
        base_value = eval("self.#{attr}")
        # timezoneの考慮が必要
        # see:Redmine::I18n#format_time
        zone = User.current.time_zone
        base_value &&= zone ? base_value.in_time_zone(zone) : (base_value.utc? ? base_value.localtime : base_value)
        base_value &&= base_value.strftime("%H:%M")
        val || base_value
      end
      
      define_method("#{prefix}_hm=") do |val|
        instance_variable_set("@#{prefix}_hm", val)
        set_date_time_attr("#{attr}", eval("#{prefix}_date"), val)
      end
    end
  end
  
  attr_accessor_separate_datetime :disaster_occurred_at, :general_prefectural_antidisaster_headquarter_status_at,
                                  :general_municipal_antidisaster_headquarter_status_at, :prefectural_antidisaster_headquarter_status_at,
                                  :municipal_antidisaster_headquarter_status_at, :disaster_relief_act_applied_at
  
  # チケット登録処理
  # ==== Args
  # _project_ :: Projectオブジェクト
  # ==== Return
  # Issueオブジェクト配列
  # ==== Raise
  def self.create_issues(project)
    issues = []
    ### 公共コモンズ用チケット登録
    issues << self.create_commons_issue(project)
    ### Applic用チケット登録
    issues << self.create_applic_issue(project)
    return issues
  end
  
  # Applic用チケット登録処理
  # ==== Args
  # _project_ :: Projectオブジェクト
  # ==== Return
  # Issueオブジェクト
  # ==== Raise
  def self.create_applic_issue(project)
    # TODO:
  end
  
  # 公共コモンズ用チケット登録処理
  # ==== Args
  # _project_ :: Projectオブジェクト
  # ==== Return
  # Issueオブジェクト
  # ==== Raise
  def self.create_commons_issue(project)
    # TODO:
  end
  
  private
  # 日付、時刻から、attrを設定します。
  # 不正な引数の場合は、nilを設定します。
  # ==== Args
  # _attr_ :: attr
  # _date_ :: 日付（Dateもしくは文字列）
  # _hm_ :: 時刻（文字列）
  # ==== Return
  # ==== Raise
  def set_date_time_attr(attr, date, hm)
    begin
      date = Date.strptime(date.to_s, "%Y-%m-%d") unless date.is_a?(Date)
    rescue
      write_attribute(attr, nil)
      return
    end
    year, month, day = date.year, date.month, date.day
    unless /^(0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9])$/ =~ hm
      write_attribute(attr, nil)
      return
    end
    hour,min = $1, $2
    write_attribute(attr, Time.local(year, month, day, hour, min))
  end
  
end

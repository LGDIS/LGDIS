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
  # _tracker_ids_ :: トラッカーID群
  # ==== Return
  # Issueオブジェクト配列
  # ==== Raise
  def self.create_issues(project, tracker_ids)
    tracker_ids = [tracker_ids] unless tracker_ids.is_a?(Array)
    issues = []
    tracker_ids.each do |t|
      case t.to_s
      when "17"
        ### 【消防庁様式】被害要約報告（概況）
        issues << self.create_general_damage_situation_issue(project)
      when "16"
        ### 【消防庁様式】災害対策本部設置報告
        issues << self.create_antidisaster_headquarter_issue(project)
      when "18"
        ### 【消防庁様式】被害要約報告（状況）
        issues << self.create_damage_infomation_issue(project)
      end
    end
    return issues
  end
  
  # 【消防庁様式】被害要約報告（概況）チケット登録処理
  # 作成するxml_bodyは、Applic用です。
  # ==== Args
  # _project_ :: Projectオブジェクト
  # ==== Return
  # Issueオブジェクト
  # ==== Raise
  def self.create_general_damage_situation_issue(project)
    return nil unless dd = DisasterDamage.first
    
    doc =  REXML::Document.new
    doc << REXML::XMLDecl.new('1.0', 'UTF-8')
    root = doc.add_element("_災害概況即報") # Root
    
    root.add_element("災害識別情報").add_text("#{project.disaster_code}")
    root.add_element("災害名").add_text("#{project.name}")
    root.add_element("報告番号").add_text("")
    
    node_report = root.add_element("報告日時")
    node_report_date = node_report.add_element("日付")
    node_report_date.add_element("年").add_text("")
    node_report_date.add_element("月").add_text("")
    node_report_date.add_element("日").add_text("")
    node_report.add_element("時").add_text("")
    node_report.add_element("分").add_text("")
    node_report.add_element("秒").add_text("")
    
    root.add_element("都道府県").add_text("")
    root.add_element("市町村_消防本部名").add_text("")
    
    node_reporter = root.add_element("報告者名")
    node_reporter.add_element("職員番号").add_text("")
    node_reporter_name = node_reporter.add_element("氏名")
    node_reporter_name.add_element("外字氏名").add_text("")
    node_reporter_name.add_element("内字氏名").add_text("")
    node_reporter_name.add_element("フリガナ").add_text("")
    node_reporter_staff = node_reporter.add_element("職員別名称")
    node_reporter_staff.add_element("外字氏名").add_text("")
    node_reporter_staff.add_element("内字氏名").add_text("")
    node_reporter_staff.add_element("フリガナ").add_text("")
    
    root.add_element("外字発生場所").add_text("")
    root.add_element("内字発生場所").add_text("#{dd.disaster_occurred_location}")
    
    node_occurred = root.add_element("発生日時")
    node_occurred_date = node_occurred.add_element("日付")
    node_occurred_date.add_element("年").add_text("#{dd.disaster_occurred_at.try(:year)}")
    node_occurred_date.add_element("月").add_text("#{dd.disaster_occurred_at.try(:month)}")
    node_occurred_date.add_element("日").add_text("#{dd.disaster_occurred_at.try(:day)}")
    node_occurred.add_element("時").add_text("#{dd.disaster_occurred_at.try(:hour)}")
    node_occurred.add_element("分").add_text("#{dd.disaster_occurred_at.try(:min)}")
    node_occurred.add_element("秒").add_text("#{dd.disaster_occurred_at.try(:sec)}")
    
    root.add_element("災害の概況").add_text("#{dd.general_disaster_situation}")
    
    node_casualty = root.add_element("死傷者")
    node_casualty.add_element("死者").add_text("#{dd.general_dead_count}")
    node_casualty.add_element("不明").add_text("#{dd.general_missing_count}")
    node_casualty.add_element("負傷者").add_text("#{dd.general_injured_count}")
    node_casualty.add_element("計").add_text("#{int_sum(dd.general_dead_count, dd.general_missing_count, dd.general_injured_count)}")
    
    node_building = root.add_element("住家")
    node_building.add_element("全壊_棟").add_text("#{dd.general_complete_collapse_houses_count}")
    node_building.add_element("一部破損_棟").add_text("#{dd.general_partial_damage_houses_count}")
    node_building.add_element("半壊_棟").add_text("#{dd.general_half_collapse_houses_count}")
    node_building.add_element("床上浸水_棟").add_text("#{dd.general_inundation_above_floor_level_houses_count}")
    
    root.add_element("被害の状況").add_text("#{dd.general_damages_status}")
    
    node_prefectural_ah = root.add_element("災害対策本部等設置状況_都道府県")
    node_prefectural_ah.add_element("設置状況").add_text("#{dd.general_prefectural_antidisaster_headquarter_status}")
    node_prefectural_ah_at = node_prefectural_ah.add_element("設置状況日時")
    node_prefectural_ah_at_date = node_prefectural_ah_at.add_element("日付")
    node_prefectural_ah_at_date.add_element("年").add_text("#{dd.general_prefectural_antidisaster_headquarter_status_at.try(:year)}")
    node_prefectural_ah_at_date.add_element("月").add_text("#{dd.general_prefectural_antidisaster_headquarter_status_at.try(:month)}")
    node_prefectural_ah_at_date.add_element("日").add_text("#{dd.general_prefectural_antidisaster_headquarter_status_at.try(:day)}")
    node_prefectural_ah_at.add_element("時").add_text("#{dd.general_prefectural_antidisaster_headquarter_status_at.try(:hour)}")
    node_prefectural_ah_at.add_element("分").add_text("#{dd.general_prefectural_antidisaster_headquarter_status_at.try(:min)}")
    node_prefectural_ah_at.add_element("秒").add_text("#{dd.general_prefectural_antidisaster_headquarter_status_at.try(:sec)}")
    
    node_municipal_ah = root.add_element("災害対策本部等設置状況_市町村")
    node_municipal_ah.add_element("災害対策本部等設置市町村").add_text("#{dd.general_municipal_antidisaster_headquarter_of}")
    node_municipal_ah.add_element("設置状況").add_text("#{dd.general_municipal_antidisaster_headquarter_status}")
    node_municipal_ah_at = node_municipal_ah.add_element("設置状況日時")
    node_municipal_ah_at_date = node_municipal_ah_at.add_element("日付")
    node_municipal_ah_at_date.add_element("年").add_text("#{dd.general_municipal_antidisaster_headquarter_status_at.try(:year)}")
    node_municipal_ah_at_date.add_element("月").add_text("#{dd.general_municipal_antidisaster_headquarter_status_at.try(:month)}")
    node_municipal_ah_at_date.add_element("日").add_text("#{dd.general_municipal_antidisaster_headquarter_status_at.try(:day)}")
    node_municipal_ah_at.add_element("時").add_text("#{dd.general_municipal_antidisaster_headquarter_status_at.try(:hour)}")
    node_municipal_ah_at.add_element("分").add_text("#{dd.general_municipal_antidisaster_headquarter_status_at.try(:min)}")
    node_municipal_ah_at.add_element("秒").add_text("#{dd.general_municipal_antidisaster_headquarter_status_at.try(:sec)}")
    
    root.add_element("応急対策の状況").add_text("#{dd.emergency_measures_status}")
    
    issue = Issue.new
    issue.tracker_id = 17
    issue.project_id = project.id
    issue.subject    = "災害概況即報 #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}"
    issue.author_id  = User.current.id
    issue.xml_body   = doc.to_s
    issue.save!
    
    return issue
  end
  
  # 【消防庁様式】被害要約報告（状況）チケット登録処理
  # 作成するxml_bodyは、公共コモンズ用です。
  # ==== Args
  # _project_ :: Projectオブジェクト
  # ==== Return
  # Issueオブジェクト
  # ==== Raise
  def self.create_damage_infomation_issue(project)
    return nil unless dd = DisasterDamage.first
    
    doc =  REXML::Document.new
    doc << REXML::XMLDecl.new('1.0', 'UTF-8')
    root = doc.add_element("pcx_di:DamageInformation") # Root
    
    node_disaster = root.add_element("pcx_eb:Disaster")
    node_disaster.add_element("pcx_eb:DisasterName").add_text("#{project.name}")
    root.add_element("pcx_di:ComplementaryInfo")
    
    # 人的被害
    # 子要素がすべてブランクの場合、親要素を生成しない
    if dd.dead_count.present? || dd.missing_count.present? ||
        dd.seriously_injured_count.present? || dd.slightly_injured_count.present?
      # 親要素の追加
      node_human_damages = root.add_element("pcx_di:HumanDamages")
      # 死者
      node_human_damages.add_element("pcx_di:HumanDamage",
                                      {"pcx_di:humanDamageType" => "死者",
                                       "pcx_di:counterUnit" => "人"})
                        .add_text("#{dd.dead_count}") if dd.dead_count.present?
      # 行方不明者数
      node_human_damages.add_element("pcx_di:HumanDamage",
                                      {"pcx_di:humanDamageType" => "行方不明者数",
                                       "pcx_di:counterUnit" => "人"})
                        .add_text("#{dd.missing_count}") if dd.missing_count.present?
      # 負傷者_重傷
      node_human_damages.add_element("pcx_di:HumanDamage",
                                      {"pcx_di:humanDamageType" => "負傷者_重傷",
                                       "pcx_di:counterUnit" => "人"})
                        .add_text("#{dd.seriously_injured_count}") if dd.seriously_injured_count.present?
      # 負傷者_軽傷
      node_human_damages.add_element("pcx_di:HumanDamage",
                                      {"pcx_di:humanDamageType" => "負傷者_軽傷",
                                       "pcx_di:counterUnit" => "人"})
                        .add_text("#{dd.slightly_injured_count}") if dd.slightly_injured_count.present?
    end
    
    # 住家被害
    # 子要素がすべてブランクの場合、親要素を生成しない
    if dd.complete_collapse_houses_count.present? || dd.complete_collapse_households_count.present? || dd.complete_collapse_people_count.present? ||
        dd.half_collapse_houses_count.present? || dd.half_collapse_households_count.present? || dd.half_collapse_people_count.present? ||
        dd.partial_damage_houses_count.present? || dd.partial_damage_households_count.present? || dd.partial_damage_people_count.present? ||
        dd.inundation_above_floor_level_houses_count.present? || dd.inundation_above_floor_level_households_count.present? || dd.inundation_above_floor_level_people_count.present? ||
        dd.inundation_under_floor_level_houses_count.present? || dd.inundation_under_floor_level_households_count.present? || dd.inundation_under_floor_level_people_count.present?
      # 親要素の追加
      node_house_damages = root.add_element("pcx_di:HouseDamages")
      # 全壊
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "全壊",
                                       "pcx_di:counterUnit" => "棟"})
                        .add_text("#{dd.complete_collapse_houses_count}") if dd.complete_collapse_houses_count.present?
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "全壊",
                                       "pcx_di:counterUnit" => "世帯"})
                        .add_text("#{dd.complete_collapse_households_count}") if dd.complete_collapse_households_count.present?
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "全壊",
                                       "pcx_di:counterUnit" => "人"})
                        .add_text("#{dd.complete_collapse_people_count}") if dd.complete_collapse_people_count.present?
      # 半壊
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "半壊",
                                       "pcx_di:counterUnit" => "棟"})
                        .add_text("#{dd.half_collapse_houses_count}") if dd.half_collapse_houses_count.present?
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "半壊",
                                       "pcx_di:counterUnit" => "世帯"})
                        .add_text("#{dd.half_collapse_households_count}") if dd.half_collapse_households_count.present?
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "半壊",
                                       "pcx_di:counterUnit" => "人"})
                        .add_text("#{dd.half_collapse_people_count}") if dd.half_collapse_people_count.present?
      # 一部破損
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "一部破損",
                                       "pcx_di:counterUnit" => "棟"})
                        .add_text("#{dd.partial_damage_houses_count}") if dd.partial_damage_houses_count.present?
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "一部破損",
                                       "pcx_di:counterUnit" => "世帯"})
                        .add_text("#{dd.partial_damage_households_count}") if dd.partial_damage_households_count.present?
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "一部破損",
                                       "pcx_di:counterUnit" => "人"})
                        .add_text("#{dd.partial_damage_people_count}") if dd.partial_damage_people_count.present?
      # 床上浸水
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "床上浸水",
                                       "pcx_di:counterUnit" => "棟"})
                        .add_text("#{dd.inundation_above_floor_level_houses_count}") if dd.inundation_above_floor_level_houses_count?
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "床上浸水",
                                       "pcx_di:counterUnit" => "世帯"})
                        .add_text("#{dd.inundation_above_floor_level_households_count}") if dd.inundation_above_floor_level_households_count.present?
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "床上浸水",
                                       "pcx_di:counterUnit" => "人"})
                        .add_text("#{dd.inundation_above_floor_level_people_count}") if dd.inundation_above_floor_level_people_count.present?
      # 床下浸水
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "床下浸水",
                                       "pcx_di:counterUnit" => "棟"})
                        .add_text("#{dd.inundation_under_floor_level_houses_count}") if dd.inundation_under_floor_level_houses_count
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "床下浸水",
                                       "pcx_di:counterUnit" => "世帯"})
                        .add_text("#{dd.inundation_under_floor_level_households_count}") if dd.inundation_under_floor_level_households_count.present?
      node_house_damages.add_element("pcx_di:HouseDamage",
                                      {"pcx_di:houseDamageType" => "床下浸水",
                                       "pcx_di:counterUnit" => "人"})
                        .add_text("#{dd.inundation_under_floor_level_people_count}") if dd.inundation_under_floor_level_people_count.present?
    end
    
    # 非住家被害
    # 子要素がすべてブランクの場合、親要素を生成しない
    if dd.damaged_public_building_count.present? || dd.damaged_other_building_count.present?
      # 親要素の追加
      node_building_damages = root.add_element("pcx_di:BuildingDamages")
      # 公共建物
      node_building_damages.add_element("pcx_di:BuildingDamage",
                                         {"pcx_di:buildingDamageType" => "公共建物",
                                          "pcx_di:counterUnit" => "棟"})
                           .add_text("#{dd.damaged_public_building_count}") if dd.damaged_public_building_count.present?
      # その他
      node_building_damages.add_element("pcx_di:BuildingDamage",
                                         {"pcx_di:buildingDamageType" => "その他",
                                          "pcx_di:counterUnit" => "棟"})
                           .add_text("#{dd.damaged_other_building_count}") if dd.damaged_other_building_count.present?
    end
    
    # その他
    # 子要素がすべてブランクの場合、親要素を生成しない
    if dd.buried_or_washed_out_rice_field_ha.present? || dd.under_water_rice_field_ha.present? ||
        dd.buried_or_washed_out_upland_field_ha.present? || dd.under_water_upland_field_ha.present? ||
        dd.damaged_educational_facilities_count.present? || dd.damaged_hospitals_count.present? ||
        dd.damaged_roads_count.present? || dd.damaged_bridges_count.present? ||
        dd.damaged_rivers_count.present? || dd.damaged_harbors_count.present? ||
        dd.damaged_sand_control_count.present? || dd.damaged_cleaning_facilities_count.present? ||
        dd.landslides_count.present? || dd.closed_lines_count.present? ||
        dd.damaged_ships_count.present? || dd.water_failure_houses_count.present? ||
        dd.dead_telephone_lines_count.present? || dd.blackout_houses_count.present? ||
        dd.gas_supply_stopped_houses_count.present? || dd.damaged_concrete_block_walls_count.present?
      # 親要素の追加
      node_other_damages = root.add_element("pcx_di:OtherDamages")
      # 田_流出埋没
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "田_流出埋没",
                                       "pcx_di:counterUnit" => "ha"})
                        .add_text("#{dd.buried_or_washed_out_rice_field_ha}") if dd.buried_or_washed_out_rice_field_ha.present?
      # 田_冠水
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "田_冠水",
                                       "pcx_di:counterUnit" => "ha"})
                        .add_text("#{dd.under_water_rice_field_ha}") if dd.under_water_rice_field_ha.present?
      # 畑_流出埋没
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "畑_流出埋没",
                                       "pcx_di:counterUnit" => "ha"})
                        .add_text("#{dd.buried_or_washed_out_upland_field_ha}") if dd.buried_or_washed_out_upland_field_ha.present?
      # 畑_冠水
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "畑_冠水",
                                       "pcx_di:counterUnit" => "ha"})
                        .add_text("#{dd.under_water_upland_field_ha}") if dd.under_water_upland_field_ha.present?
      # 文教施設
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "文教施設",
                                       "pcx_di:counterUnit" => "箇所"})
                        .add_text("#{dd.damaged_educational_facilities_count}") if dd.damaged_educational_facilities_count.present?
      # 病院
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "病院",
                                       "pcx_di:counterUnit" => "箇所"})
                        .add_text("#{dd.damaged_hospitals_count}") if dd.damaged_hospitals_count.present?
      # 道路
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "道路",
                                       "pcx_di:counterUnit" => "箇所"})
                        .add_text("#{dd.damaged_roads_count}") if dd.damaged_roads_count.present?
      # 橋りょう
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "橋りょう",
                                       "pcx_di:counterUnit" => "箇所"})
                        .add_text("#{dd.damaged_bridges_count}") if dd.damaged_bridges_count.present?
      # 河川
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "河川",
                                       "pcx_di:counterUnit" => "箇所"})
                        .add_text("#{dd.damaged_rivers_count}") if dd.damaged_rivers_count.present?
      # 港湾
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "港湾",
                                       "pcx_di:counterUnit" => "箇所"})
                        .add_text("#{dd.damaged_harbors_count}") if dd.damaged_harbors_count.present?
      # 砂防
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "砂防",
                                       "pcx_di:counterUnit" => "箇所"})
                        .add_text("#{dd.damaged_sand_control_count}") if dd.damaged_sand_control_count.present?
      # 清掃施設
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "清掃施設",
                                       "pcx_di:counterUnit" => "箇所"})
                        .add_text("#{dd.damaged_cleaning_facilities_count}") if dd.damaged_cleaning_facilities_count.present?
      # 崖くずれ
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "崖くずれ",
                                       "pcx_di:counterUnit" => "箇所"})
                        .add_text("#{dd.landslides_count}") if dd.landslides_count.present?
      # 鉄道不通
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "鉄道不通",
                                       "pcx_di:counterUnit" => "箇所"})
                        .add_text("#{dd.closed_lines_count}") if dd.closed_lines_count.present?
      # 被害船舶
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "被害船舶",
                                       "pcx_di:counterUnit" => "隻"})
                        .add_text("#{dd.damaged_ships_count}") if dd.damaged_ships_count.present?
      # 水道
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "水道",
                                       "pcx_di:counterUnit" => "戸"})
                        .add_text("#{dd.water_failure_houses_count}") if dd.water_failure_houses_count.present?
      # 電話
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "電話",
                                       "pcx_di:counterUnit" => "回線"})
                        .add_text("#{dd.dead_telephone_lines_count}") if dd.dead_telephone_lines_count.present?
      # 電気
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "電気",
                                       "pcx_di:counterUnit" => "戸"})
                        .add_text("#{dd.blackout_houses_count}") if dd.blackout_houses_count.present?
      # ガス
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "ガス",
                                       "pcx_di:counterUnit" => "戸"})
                        .add_text("#{dd.gas_supply_stopped_houses_count}") if dd.gas_supply_stopped_houses_count.present?
      # ブロック塀等
      node_other_damages.add_element("pcx_di:OtherDamage",
                                      {"pcx_di:otherDamageType" => "ブロック塀等",
                                       "pcx_di:counterUnit" => "箇所"})
                        .add_text("#{dd.damaged_concrete_block_walls_count}") if dd.damaged_concrete_block_walls_count.present?
    end
    
    # り災
    # 子要素がすべてブランクの場合、親要素を生成しない
    if dd.sufferer_houses_count.present? || dd.sufferer_people_count.present?
      # 親要素の追加
      node_sufferers = root.add_element("pcx_di:Sufferers")
      # り災世帯数
      node_sufferers.add_element("pcx_di:Sufferer",
                                  {"pcx_di:suffererDamageType" => "り災世帯数",
                                   "pcx_di:counterUnit" => "世帯"})
                    .add_text("#{dd.sufferer_houses_count}") if dd.sufferer_houses_count.present?
      # り災者数
      node_sufferers.add_element("pcx_di:Sufferer",
                                  {"pcx_di:suffererDamageType" => "り災者数",
                                   "pcx_di:counterUnit" => "人"})
                    .add_text("#{dd.sufferer_people_count}") if dd.sufferer_people_count.present?
    end
    
    # 火災発生
    # 子要素がすべてブランクの場合、親要素を生成しない
    if dd.fire_occurred_buildings_count.present? || dd.fire_occurred_dangerous_substances_count.present? || dd.fire_occurred_others_count.present?
      # 親要素の追加
      node_fire_damages = root.add_element("pcx_di:FireDamages")
      # 建物
      node_fire_damages.add_element("pcx_di:FireDamage",
                                     {"pcx_di:fireDamageType" => "建物",
                                      "pcx_di:counterUnit" => "件"})
                       .add_text("#{dd.fire_occurred_buildings_count}") if dd.fire_occurred_buildings_count.present?
      # 危険物
      node_fire_damages.add_element("pcx_di:FireDamage",
                                     {"pcx_di:fireDamageType" => "危険物",
                                      "pcx_di:counterUnit" => "件"})
                       .add_text("#{dd.fire_occurred_dangerous_substances_count}") if dd.fire_occurred_dangerous_substances_count.present?
      # その他
      node_fire_damages.add_element("pcx_di:FireDamage",
                                     {"pcx_di:fireDamageType" => "その他",
                                      "pcx_di:counterUnit" => "件"})
                       .add_text("#{dd.fire_occurred_others_count}") if dd.fire_occurred_others_count.present?
    end
    
    # 被害額
    # 子要素がすべてブランクの場合、親要素を生成しない
    if dd.public_educational_buildings_losses_amount.present? || dd.agriculture_forestry_and_fisheries_buildings_losses_amount.present? ||
          dd.public_civil_buildings_losses_amount.present? ||
          dd.agriculture_losses_amount.present? || dd.forestry_losses_amount.present? ||
          dd.livestock_losses_amount.present? || dd.fisheries_losses_amount.present? ||
          dd.commerce_and_industry_losses_amount.present? || dd.other_losses_amount.present?
      # 親要素の追加
      node_losses = root.add_element("pcx_di:Losses")
      
      # 施設被害額
      # 子要素がすべてブランクの場合、親要素を生成しない
      if dd.public_educational_buildings_losses_amount.present? || dd.agriculture_forestry_and_fisheries_buildings_losses_amount.present? ||
            dd.public_civil_buildings_losses_amount.present?
        # 親要素の追加
        node_facilities_losses = node_losses.add_element("pcx_di:FacilitiesLosses")
        # 公共文教施設
        node_facilities_losses.add_element("pcx_di:Loss",
                                            {"pcx_di:lossesDamageType" => "公共文教施設",
                                             "pcx_di:counterUnit" => "千円"})
                              .add_text("#{dd.public_educational_buildings_losses_amount}") if dd.public_educational_buildings_losses_amount.present?
        # 農林水産業施設
        node_facilities_losses.add_element("pcx_di:Loss",
                                            {"pcx_di:lossesDamageType" => "農林水産業施設",
                                             "pcx_di:counterUnit" => "千円"})
                              .add_text("#{dd.agriculture_forestry_and_fisheries_buildings_losses_amount}") if dd.agriculture_forestry_and_fisheries_buildings_losses_amount.present?
        # 公共土木施設
        node_facilities_losses.add_element("pcx_di:Loss",
                                            {"pcx_di:lossesDamageType" => "公共土木施設",
                                             "pcx_di:counterUnit" => "千円"})
                              .add_text("#{dd.public_civil_buildings_losses_amount}") if dd.public_civil_buildings_losses_amount.present?
        # 施設被害額の小計
        node_facilities_losses.add_element("pcx_di:TotalLosses", {"pcx_di:currencyUnit" => "千円"})
                              .add_text("#{int_sum(dd.public_educational_buildings_losses_amount,
                                                   dd.agriculture_forestry_and_fisheries_buildings_losses_amount,
                                                   dd.public_civil_buildings_losses_amount)}")
      end
      
      # その他の被害額
      # 子要素がすべてブランクの場合、親要素を生成しない
      if dd.agriculture_losses_amount.present? || dd.forestry_losses_amount.present? ||
            dd.livestock_losses_amount.present? || dd.fisheries_losses_amount.present? ||
            dd.commerce_and_industry_losses_amount.present? || dd.other_losses_amount.present?
        # 親要素の追加
        node_other_losses = node_losses.add_element("pcx_di:OtherLosses")
        # 農業被害
        node_other_losses.add_element("pcx_di:Loss",
                                        {"pcx_di:lossesDamageType" => "農業被害",
                                         "pcx_di:counterUnit" => "千円"})
                         .add_text("#{dd.agriculture_losses_amount}") if dd.agriculture_losses_amount.present?
        # 林業被害
        node_other_losses.add_element("pcx_di:Loss",
                                        {"pcx_di:lossesDamageType" => "林業被害",
                                         "pcx_di:counterUnit" => "千円"})
                         .add_text("#{dd.forestry_losses_amount}") if dd.forestry_losses_amount.present?
        # 畜産被害
        node_other_losses.add_element("pcx_di:Loss",
                                        {"pcx_di:lossesDamageType" => "畜産被害",
                                         "pcx_di:counterUnit" => "千円"})
                         .add_text("#{dd.livestock_losses_amount}") if dd.livestock_losses_amount.present?
        # 水産被害
        node_other_losses.add_element("pcx_di:Loss",
                                        {"pcx_di:lossesDamageType" => "水産被害",
                                         "pcx_di:counterUnit" => "千円"})
                         .add_text("#{dd.fisheries_losses_amount}") if dd.fisheries_losses_amount.present?
        # 商工被害
        node_other_losses.add_element("pcx_di:Loss",
                                        {"pcx_di:lossesDamageType" => "商工被害",
                                         "pcx_di:counterUnit" => "千円"})
                         .add_text("#{dd.commerce_and_industry_losses_amount}") if dd.commerce_and_industry_losses_amount.present?
        # その他
        node_other_losses.add_element("pcx_di:Loss",
                                        {"pcx_di:lossesDamageType" => "その他",
                                         "pcx_di:counterUnit" => "千円"})
                         .add_text("#{dd.other_losses_amount}") if dd.other_losses_amount.present?
      end
      
      # 被害総計
      node_losses.add_element("pcx_di:TotalLosses", {"pcx_di:currencyUnit" => "千円"})
                 .add_text("#{int_sum(dd.public_educational_buildings_losses_amount,
                                      dd.agriculture_forestry_and_fisheries_buildings_losses_amount,
                                      dd.public_civil_buildings_losses_amount,
                                      dd.agriculture_losses_amount,
                                      dd.forestry_losses_amount,
                                      dd.livestock_losses_amount,
                                      dd.fisheries_losses_amount,
                                      dd.commerce_and_industry_losses_amount,
                                      dd.other_losses_amount)}")
    end
    
    # 消防
    # 子要素がすべてブランクの場合、親要素を生成しない
    if dd.turnout_fire_station_firefighter_count.present? || dd.turnout_fire_company_firefighter_count.present?
      # 親要素の追加
      node_firefighter = root.add_element("pcx_di:Firefighter")
      # 消防職員出動延人数
      node_firefighter.add_element("pcx_di:TurnoutFireStation")
                      .add_text("#{dd.turnout_fire_station_firefighter_count}") if dd.turnout_fire_station_firefighter_count.present?
      # 消防団員出動延人数
      node_firefighter.add_element("pcx_di:TurnoutFireCompany")
                      .add_text("#{dd.turnout_fire_company_firefighter_count}") if dd.turnout_fire_company_firefighter_count.present?
    end
    
    issue = Issue.new
    issue.tracker_id = 18
    issue.project_id = project.id
    issue.subject    = "被害情報 #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}"
    issue.author_id  = User.current.id
    issue.xml_body   = doc.to_s
    issue.save!
    
    return issue
  end
  
  # 【消防庁様式】災害対策本部設置報告チケット登録処理
  # 作成するxml_bodyは、公共コモンズ用です。
  # ==== Args
  # _project_ :: Projectオブジェクト
  # ==== Return
  # Issueオブジェクト
  # ==== Raise
  def self.create_antidisaster_headquarter_issue(project)
    return nil unless dd = DisasterDamage.first
    
    doc =  REXML::Document.new
    doc << REXML::XMLDecl.new('1.0', 'UTF-8')
    root = doc.add_element("pcx_ah:AntidisasterHeadquarter") # Root
    
    node_disaster = root.add_element("pcx_eb:Disaster")
    node_disaster.add_element("pcx_eb:DisasterName").add_text("#{project.name}")
    
    # 本部種別
    root.add_element("pcx_ah:Type")
        .add_text(CONST["municipal_antidisaster_headquarter_type"]["#{dd.municipal_antidisaster_headquarter_type}"]) if dd.municipal_antidisaster_headquarter_type.present?
    
    # 設置状況
    root.add_element("pcx_ah:Status")
        .add_text(CONST["municipal_antidisaster_headquarter_status"]["#{dd.municipal_antidisaster_headquarter_status}"]) if dd.municipal_antidisaster_headquarter_status.present?
    
    # 設置・解散日時
    root.add_element("pcx_ah:DateTime")
        .add_text("#{dd.municipal_antidisaster_headquarter_status_at.xmlschema}") if dd.municipal_antidisaster_headquarter_status_at.present?
    
    issue = Issue.new
    issue.tracker_id = 16
    issue.project_id = project.id
    issue.subject    = "災害対策本部設置状況 #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}"
    issue.author_id  = User.current.id
    issue.xml_body   = doc.to_s
    issue.save!
    
    return issue
  end
  
  private
  # 整数値の合計を算出します
  # ==== Args
  # _project_ :: Projectオブジェクト
  # ==== Return
  # Issueオブジェクト
  # ==== Raise
  def self.int_sum(*args)
    total = nil
    args.each do |arg|
      total = (total || 0) + arg.to_i if arg.present?
    end
    return total
  end
  
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

# encoding: utf-8
class Shelter < ActiveRecord::Base
  unloadable
  
  acts_as_paranoid
  
  belongs_to :project
  
  attr_accessible :name,:name_kana,:address,:phone,:fax,:e_mail,:person_responsible,
                  :shelter_type,:shelter_type_detail,:shelter_sort,:opened_date,:opened_hm,
                  :closed_date, :closed_hm,:capacity,:status,:head_count_voluntary,
                  :households_voluntary,:checked_date, :checked_hm,:manager_code,:manager_name,
                  :manager_another_name,:reported_date, :reported_hm,:building_damage_info,
                  :electric_infra_damage_info,:communication_infra_damage_info,
                  :other_damage_info,:usable_flag,:openable_flag,:note,
                  :as => :shelter
  
  attr_accessible :head_count,:households,:injury_count,:upper_care_level_three_count,
                  :elderly_alone_count,:elderly_couple_count,:bedridden_elderly_count,
                  :elderly_dementia_count,:rehabilitation_certificate_count,
                  :physical_disability_certificate_count,
                  :as => :count
  
  # 正の整数チェック用オプションハッシュ値
  POSITIVE_INTEGER = {:only_integer => true,
                      :greater_than_or_equal_to => 0,
                      :less_than_or_equal_to => 2147483647,
                      :allow_blank => true}.freeze
  
  # コンスタント存在チェック用
  CONST = Constant::hash_for_table(self.table_name).freeze
  
  validates :project, :presence => true
  validates :disaster_code, :presence => true, 
                :length => {:maximum => 20}
  validates :name, :presence => true, 
                :length => {:maximum => 30}
  validates :name_kana,
                :length => {:maximum => 60}
  validates :address, :presence => true, 
                :length => {:maximum => 200}
  validates :phone,
                :length => {:maximum => 20},
                :custom_format => {:type => :phone_number}
  validates :fax,
                :length => {:maximum => 20},
                :custom_format => {:type => :phone_number}
  validates :e_mail,
                :length => {:maximum => 255},
                :custom_format => {:type => :mail_address}
  validates :person_responsible,
                :length => {:maximum => 100}
  validates :shelter_type, :presence => true,
                :inclusion => {:in => CONST[:shelter_type.to_s].keys, :allow_blank => true}
  validates :shelter_type_detail,
                :length => {:maximum => 255}
  validates :shelter_sort, :presence => true,
                :inclusion => {:in => CONST[:shelter_sort.to_s].keys, :allow_blank => true}
  # validates :opened_at
  validates :opened_date,
                :custom_format => {:type => :date}
  validates :opened_date, :presence => true, :unless => "opened_hm.blank?"
  validates :opened_hm,
                :custom_format => {:type => :time}
  validates :opened_hm, :presence => true, :unless => "opened_date.blank?"
  # validates :closed_at
  validates :closed_date,
                :custom_format => {:type => :date}
  validates :closed_date, :presence => true, :unless => "closed_hm.blank?"
  validates :closed_hm,
                :custom_format => {:type => :time}
  validates :closed_hm, :presence => true, :unless => "closed_date.blank?"
  validates :capacity,
                :numericality => POSITIVE_INTEGER
  validates :status,
                :inclusion => {:in => CONST[:status.to_s].keys, :allow_blank => true}
  validates :head_count,
                :numericality => POSITIVE_INTEGER
  validates :head_count_voluntary,
                :numericality => POSITIVE_INTEGER
  validates :households,
                :numericality => POSITIVE_INTEGER
  validates :households_voluntary,
                :numericality => POSITIVE_INTEGER
  # validates :checked_at
  validates :checked_date,
                :custom_format => {:type => :date}
  validates :checked_date, :presence => true, :unless => "checked_hm.blank?"
  validates :checked_hm,
                :custom_format => {:type => :time}
  validates :checked_hm, :presence => true, :unless => "checked_date.blank?"
  validates :manager_code,
                :length => {:maximum => 10}
  validates :manager_name,
                :length => {:maximum => 100}
  validates :manager_another_name,
                :length => {:maximum => 100}
  # validates :reported_at
  validates :reported_date,
                :custom_format => {:type => :date}
  validates :reported_date, :presence => true, :unless => "reported_hm.blank?"
  validates :reported_hm,
                :custom_format => {:type => :time}
  validates :reported_hm, :presence => true, :unless => "reported_date.blank?"
  validates :building_damage_info,
                :length => {:maximum => 4000}
  validates :electric_infra_damage_info,
                :length => {:maximum => 4000}
  validates :communication_infra_damage_info,
                :length => {:maximum => 4000}
  validates :other_damage_info,
                :length => {:maximum => 4000}
  validates :usable_flag,
                :inclusion => {:in => CONST[:usable_flag.to_s].keys, :allow_blank => true}
  validates :openable_flag,
                :inclusion => {:in => CONST[:openable_flag.to_s].keys, :allow_blank => true}
  validates :injury_count,
                :numericality => POSITIVE_INTEGER
  validates :upper_care_level_three_count,
                :numericality => POSITIVE_INTEGER
  validates :elderly_alone_count,
                :numericality => POSITIVE_INTEGER
  validates :elderly_couple_count,
                :numericality => POSITIVE_INTEGER
  validates :bedridden_elderly_count,
                :numericality => POSITIVE_INTEGER
  validates :elderly_dementia_count,
                :numericality => POSITIVE_INTEGER
  validates :rehabilitation_certificate_count,
                :numericality => POSITIVE_INTEGER
  validates :physical_disability_certificate_count,
                :numericality => POSITIVE_INTEGER
  validates :note,
                :length => {:maximum => 4000}
  
  before_create :number_shelter_code
  
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
  
  attr_accessor_separate_datetime :opened_at,:closed_at,:checked_at,:reported_at
  
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
    p date,hm
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
  
  # 避難所識別番号を設定します。
  # ==== Args
  # ==== Return
  # ==== Raise
  def number_shelter_code
    # JISコード
    code1 = "04" # JISコード/都道府県コード(2桁) 宮城県
    code2 = "202" # JISコード/市区町村コード(3桁) 石巻市
    code3 = "I" # 固定(1桁) I
    code4 = "12345" # TODO:管理番号(5～14桁)
    
    self.shelter_code = code1 + code2 + code3 + code4
  end
end

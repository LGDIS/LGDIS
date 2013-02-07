# encoding: utf-8
class EvacuationAdvisory < ActiveRecord::Base
  unloadable
  acts_as_paranoid
  
  belongs_to :project
  
#   attr_accessible :name,:name_kana,:address,:phone,:fax,:e_mail,:person_responsible,
#                   :advisory_type,:advisory_type_detail,:sort_criteria,:opened_date,:opened_hm,
#                   :closed_date, :closed_hm,:capacity,:status,:head_count_voluntary,
#                   :households_voluntary,:checked_date, :checked_hm,:manager_code,:manager_name,
#                   :manager_another_name,:reported_date, :reported_hm,:building_damage_info,
#                   :electric_infra_damage_info,:communication_infra_damage_info,
#                   :other_damage_info,:usable_flag,:openable_flag,:remarks,
#                   :as => :evacuation_advisory
#   
#   attr_accessible :head_count,:households,:injury_count,:upper_care_level_three_count,
#                   :elderly_alone_count,:elderly_couple_count,:bedridden_elderly_count,
#                   :elderly_dementia_count,:rehabilitation_certificate_count,
#                   :physical_disability_certificate_count,
#                   :as => :count
#   
  ##正の整数チェック用オプションハッシュ値
  POSITIVE_INTEGER = {:only_integer => true,
                      :greater_than_or_equal_to => 0,
                      :less_than_or_equal_to => 2147483647,
                      :allow_blank => true}.freeze
  
  ##コンスタント存在チェック用
  CONST = Constant::hash_for_table(self.table_name).freeze
  
  validates :project, :presence => true
  validates :advisory_type, :presence => true,
                :inclusion => {:in => CONST[:advisory_type.to_s].keys, :allow_blank => true}
#   validates :advisory_type_detail,
#                 :length => {:maximum => 255}
	validates :sort_criteria, :presence => true,
								:inclusion => {:in => CONST[:sort_criteria.to_s].keys, :allow_blank => true}
	validates :issue_or_lift,
								:inclusion => {:in => CONST[:issue_or_lift.to_s].keys, :allow_blank => true}
#:NoMethodError (undefined method `keys' for nil:NilClass):
#   validates :area,
#                 :inclusion => {:in => CONST[:area.to_s].keys, :allow_blank => true}
	#
#   validates :disaster_code, :presence => true, 
#                 :length => {:maximum => 20}
#   validates :name, :presence => true, 
#                 :length => {:maximum => 30}
#   validates :name_kana,
#                 :length => {:maximum => 60}
#   validates :address, :presence => true, 
#                 :length => {:maximum => 200}
#   validates :phone,
#                 :length => {:maximum => 20},
#                 :custom_format => {:type => :phone_number}
#   validates :fax,
#                 :length => {:maximum => 20},
#                 :custom_format => {:type => :phone_number}
#   validates :e_mail,
#                 :length => {:maximum => 255},
#                 :custom_format => {:type => :mail_address}
#   validates :person_responsible,
#                 :length => {:maximum => 100}
##  validates :opened_at
#   validates :opened_date,
#                 :custom_format => {:type => :date}
#   validates :opened_date, :presence => true, :unless => "opened_hm.blank?"
#   validates :opened_hm,
#                 :custom_format => {:type => :time}
#   validates :opened_hm, :presence => true, :unless => "opened_date.blank?"
##  validates :closed_at
#   validates :closed_date,
#                 :custom_format => {:type => :date}
#   validates :closed_date, :presence => true, :unless => "closed_hm.blank?"
#   validates :closed_hm,
#                 :custom_format => {:type => :time}
#   validates :closed_hm, :presence => true, :unless => "closed_date.blank?"
#   validates :capacity,
#                 :numericality => POSITIVE_INTEGER
#   validates :head_count,
#                 :numericality => POSITIVE_INTEGER
#   validates :head_count_voluntary,
#                 :numericality => POSITIVE_INTEGER
#   validates :households,
#                 :numericality => POSITIVE_INTEGER
#   validates :households_voluntary,
#                 :numericality => POSITIVE_INTEGER
## validates :checked_at
#   validates :checked_date,
#                 :custom_format => {:type => :date}
#   validates :checked_date, :presence => true, :unless => "checked_hm.blank?"
#   validates :checked_hm,
#                 :custom_format => {:type => :time}
#   validates :checked_hm, :presence => true, :unless => "checked_date.blank?"
#   validates :manager_code,
#                 :length => {:maximum => 10}
#   validates :manager_name,
#                 :length => {:maximum => 100}
#   validates :manager_another_name,
#                 :length => {:maximum => 100}
##  validates :reported_at
#   validates :reported_date,
#                 :custom_format => {:type => :date}
#   validates :reported_date, :presence => true, :unless => "reported_hm.blank?"
#   validates :reported_hm,
#                 :custom_format => {:type => :time}
#   validates :reported_hm, :presence => true, :unless => "reported_date.blank?"
#   validates :building_damage_info,
#                 :length => {:maximum => 4000}
#   validates :electric_infra_damage_info,
#                 :length => {:maximum => 4000}
#   validates :communication_infra_damage_info,
#                 :length => {:maximum => 4000}
#   validates :other_damage_info,
#                 :length => {:maximum => 4000}
#   validates :openable_flag,
#                 :inclusion => {:in => CONST[:openable_flag.to_s].keys, :allow_blank => true}
#   validates :injury_count,
#                 :numericality => POSITIVE_INTEGER
#   validates :upper_care_level_three_count,
#                 :numericality => POSITIVE_INTEGER
#   validates :elderly_alone_count,
#                 :numericality => POSITIVE_INTEGER
#   validates :elderly_couple_count,
#                 :numericality => POSITIVE_INTEGER
#   validates :bedridden_elderly_count,
#                 :numericality => POSITIVE_INTEGER
#   validates :elderly_dementia_count,
#                 :numericality => POSITIVE_INTEGER
#   validates :rehabilitation_certificate_count,
#                 :numericality => POSITIVE_INTEGER
#   validates :physical_disability_certificate_count,
#                 :numericality => POSITIVE_INTEGER
#   validates :remarks,
#                 :length => {:maximum => 4000}
  
  before_create :number_evacuation_advisory_code
  
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
  
  # Applic用チケット登録処理
  # ==== Args
  # _project_ :: Projectオブジェクト
  # ==== Return
  # Issueオブジェクト
  # ==== Raise
  def self.create_applic_issue(project)
    doc =  REXML::Document.new
    doc << REXML::XMLDecl.new('1.0', 'UTF-8')
    doc.add_element("_避難所") # Root
    
    # Projectに紐付く避難所を取得しXMLを生成する
    evacuation_advisories = EvacuationAdvisory.where(:project_id => project.id)
    
    evacuation_advisories.each do |evacuation_advisory|
      node_evacuation_advisory = doc.root.add_element("_避難所情報")
      
      node_evacuation_advisory.add_element("災害識別情報").add_text("#{evacuation_advisory.disaster_code}")
      node_evacuation_advisory.add_element("災害名").add_text("#{evacuation_advisory.project.name}")
      node_evacuation_advisory.add_element("都道府県").add_text("")
      node_evacuation_advisory.add_element("市町村_消防本部名").add_text("")
#       node_evacuation_advisory.add_element("避難所識別情報").add_text("#{evacuation_advisory.evacuation_code}")
#       node_evacuation_advisory.add_element("避難所名").add_text("#{evacuation_advisory.name}"
#       node_evacuation_advisory.add_element("電話番号").add_text("#{evacuation_advisory.phone}")
#       node_evacuation_advisory.add_element("FAX番号").add_text("#{evacuation_advisory.fax}")
      
      node_manager = node_evacuation_advisory.add_element("管理者")
      node_manager.add_element("職員番号").add_text("#{evacuation_advisory.staff_no}")
      node_name = node_manager.add_element("氏名")
      node_name.add_element("外字氏名").add_text("")
#       node_name.add_element("内字氏名").add_text("#{evacuation_advisory.manager_name}")
#       node_name.add_element("フリガナ").add_text("")
#       node_staff = node_manager.add_element("職員別名称")
#       node_staff.add_element("外字氏名").add_text("")
#       node_staff.add_element("内字氏名").add_text("")
#       node_staff.add_element("フリガナ").add_text("")
      
#       node_evacuation_advisory.add_element("収容人数").add_text("#{evacuation_advisory.capacity}")
      
      node_report = node_evacuation_advisory.add_element("報告日時")
      node_report_date = node_report.add_element("日付")
#       node_report_date.add_element("年").add_text("#{evacuation_advisory.reported_at.try(:year)}")
#       node_report_date.add_element("月").add_text("#{evacuation_advisory.reported_at.try(:month)}")
#       node_report_date.add_element("日").add_text("#{evacuation_advisory.reported_at.try(:day)}")
#       node_report.add_element("時").add_text("#{evacuation_advisory.reported_at.try(:hour)}")
#       node_report.add_element("分").add_text("#{evacuation_advisory.reported_at.try(:min)}")
#       node_report.add_element("秒").add_text("#{evacuation_advisory.reported_at.try(:sec)}")
      
#       node_evacuation_advisory.add_element("建物被害状況").add_text("#{evacuation_advisory.building_damage_info}")
#       node_evacuation_advisory.add_element("電力被害状況").add_text("#{evacuation_advisory.electric_infra_damage_info}")
#       node_evacuation_advisory.add_element("通信手段被害状況").add_text("#{evacuation_advisory.communication_infra_damage_info}")
#       node_evacuation_advisory.add_element("その他の被害").add_text("#{evacuation_advisory.other_damage_info}")
#       node_evacuation_advisory.add_element("使用可否").add_text("#{CONST['usable_flag'][evacuation_advisory.usable_flag]}")
#       node_evacuation_advisory.add_element("開設の可否").add_text("#{CONST['openable_flag'][evacuation_advisory.openable_flag]}")
      
      node_issued = node_evacuation_advisory.add_element("発令日時")
      node_issued_at = node_issued.add_element("日付")
      node_issued_at.add_element("年").add_text("#{evacuation_advisory.issued_at.try(:year)}")
      node_issued_at.add_element("月").add_text("#{evacuation_advisory.issued_at.try(:month)}")
      node_issued_at.add_element("日").add_text("#{evacuation_advisory.issued_at.try(:day)}")
      node_issued.add_element("時").add_text("#{evacuation_advisory.issued_at.try(:hour)}")
      node_issued.add_element("分").add_text("#{evacuation_advisory.issued_at.try(:min)}")
      node_issued.add_element("秒").add_text("#{evacuation_advisory.issued_at.try(:sec)}")
      
      node_lifted = node_evacuation_advisory.add_element("解除日時")
      node_lifted_at = node_lifted.add_element("日付")
      node_lifted_at.add_element("年").add_text("#{evacuation_advisory.lifted_at.try(:year)}")
      node_lifted_at.add_element("月").add_text("#{evacuation_advisory.lifted_at.try(:month)}")
      node_lifted_at.add_element("日").add_text("#{evacuation_advisory.lifted_at.try(:day)}")
      node_lifted.add_element("時").add_text("#{evacuation_advisory.lifted_at.try(:hour)}")
      node_lifted.add_element("分").add_text("#{evacuation_advisory.lifted_at.try(:min)}")
      node_lifted.add_element("秒").add_text("#{evacuation_advisory.lifted_at.try(:sec)}")
      
      node_evacuation_advisory.add_element("対象人数").add_text("#{evacuation_advisory.head_count}")
      node_evacuation_advisory.add_element("対象世帯数").add_text("#{evacuation_advisory.households}")
#       node_evacuation_advisory.add_element("負傷者数").add_text("#{evacuation_advisory.injury_count}")
      
#       node_aid = node_evacuation_advisory.add_element("要援護者数")
#       node_aid.add_element("要介護度3以上").add_text("#{evacuation_advisory.upper_care_level_three_count}")
#       node_aid.add_element("一人暮らし高齢者_65歳以上").add_text("#{evacuation_advisory.elderly_alone_count}")
#       node_aid.add_element("高齢者世帯_夫婦共に65歳以上").add_text("#{evacuation_advisory.elderly_couple_count}")
#       node_aid.add_element("寝たきり高齢者").add_text("#{evacuation_advisory.bedridden_elderly_count}")
#       node_aid.add_element("認知症高齢者").add_text("#{evacuation_advisory.elderly_dementia_count}")
#       node_aid.add_element("療育手帳A_A1_A2所持者").add_text("#{evacuation_advisory.rehabilitation_certificate_count}")
#       node_aid.add_element("身体障がい者手帳1_2級所持者").add_text("#{evacuation_advisory.physical_disability_certificate_count}")
      
      node_evacuation_advisory.add_element("備考").add_text("#{evacuation_advisory.remarks}")
    end
    
                          
    issue = Issue.new
    issue.tracker_id = 31
    issue.project_id = project.id
    issue.subject    = "避難勧告指示 #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}"
    issue.author_id  = User.current.id
    issue.xml_body   = doc.to_s
    issue.save!
    
    return issue
  end
  
  # 公共コモンズ用チケット登録処理
  # ==== Args
  # _project_ :: Projectオブジェクト
  # ==== Return
  # Issueオブジェクト
  # ==== Raise
  def self.create_commons_issue(project)
    # テンプレートの読み込み
    file = File.new("#{Rails.root}/plugins/lgdis/files/xml/commons.xml")
    # Xmlドキュメントの生成
    doc  = REXML::Document.new(file)
    
    # Projectに紐付く避難所を取得しXMLを生成する
    evacuation_advisories = EvacuationAdvisory.where(:project_id => project.id)
    # 避難人数、避難世帯数の集計値および避難所件数の取得
    summary  = evacuation_advisories.select("SUM(head_count) AS head_count_sum, SUM(head_count_voluntary) AS head_count_voluntary_sum,
      SUM(households) AS households_sum, SUM(households_voluntary) AS households_voluntary_sum, COUNT(*) AS count").first
    
    # EvacuationAdvisory要素の取得
    node_evacuation_advisory = doc.elements["edxlde:EDXLDistribution/commons:contentObject/edxlde:xmlContent/edxlde:embeddedXMLContent/Report/pcx_sh:EvacuationAdvisory"]
    
    # 子要素がすべてブランクの場合、親要素を生成しない
    if summary.head_count_sum.present? || summary.head_count_voluntary_sum.present? ||
      summary.households_sum.present? || summary.households_voluntary_sum.present?
      # 親要素の追加
      node_total_number = node_evacuation_advisory.add_element("pcx_sh:TotalNumber")
      # 避難総人数 自主避難人数を含む。
      node_total_number.add_element("pcx_sh:HeadCount").add_text("#{summary.head_count_sum}") if summary.head_count_sum.present?
      # 避難総人数（うち自主避難）
#       node_total_number.add_element("pcx_sh:HeadCountVoluntary").add_text("#{summary.head_count_voluntary_sum}") if summary.head_count_voluntary_sum.present?
      # 避難総世帯数
      node_total_number.add_element("pcx_sh:Households").add_text("#{summary.households_sum}") if summary.households_sum.present?
      # 避難総世帯数（うち自主避難）
#       node_total_number.add_element("pcx_sh:HouseholdsVoluntary").add_text("#{summary.households_voluntary_sum}") if summary.households_voluntary_sum.present?
    end
    
    # 開設避難所数
    node_evacuation_advisory.add_element("pcx_sh:TotalNumberOfEvacuationAdvisory").add_text("#{summary.count}") if summary.count.present?
    # ループ構造の親要素追加
    node_informations = node_evacuation_advisory.add_element("pcx_sh:Informations")
    
    evacuation_advisories.each do |evacuation_advisory|
      node_information = node_informations.add_element("pcx_sh:Information")
      
      # 子要素がすべてブランクの場合、親要素を生成しない
#       if evacuation_advisory.name.present? || evacuation_advisory.name_kana.present? ||
#         evacuation_advisory.phone.present? || evacuation_advisory.address.present?
        # 親要素の追加
#         node_location = node_information.add_element("pcx_sh:Location")
        # 所在地（緯度・経度）
        # node_location.add_element("edxlde:circle").add_text("")
        # 避難所名
#         node_location.add_element("commons:areaName").add_text("#{evacuation_advisory.name}") if evacuation_advisory.name.present?
        # 避難所名ふりがな
#         node_location.add_element("commons:areaNameKana").add_text("#{evacuation_advisory.name_kana}") if evacuation_advisory.name_kana.present?
        # 避難所連絡先
#         node_location.add_element("pcx_eb:ContactInfo", {"pcx_eb:contactType" => "phone"}).add_text("#{evacuation_advisory.phone}") if evacuation_advisory.phone.present?
        # 所在地
#         node_location.add_element("pcx_sh:Address").add_text("#{evacuation_advisory.address}") if evacuation_advisory.address.present?
#       end
      
      # 避難所種別 "避難所","臨時避難所","広域避難場所","一時避難場所"
      node_information.add_element("pcx_sh:Type").add_text(CONST["advisory_type"]["#{evacuation_advisory.advisory_type}"]) if evacuation_advisory.advisory_type.present?
      # 避難所区分 "未開設","開設","閉鎖","不明","常設"
      node_information.add_element("pcx_sh:Sort").add_text(CONST["sort_criteria"]["#{evacuation_advisory.sort_criteria}"]) if evacuation_advisory.sort_criteria.present?
      
      # 開設・閉鎖日時
      case evacuation_advisory.sort_criteria
      when "1" # 未開設
        date = nil
      when "2" # 発令
        date = evacuation_advisory.issued_at.strftime("%Y/%m/%d %H:%M:%S") if evacuation_advisory.issued_at.present?
      when "3" # 解除
        date = evacuation_advisory.lifted_at.strftime("%Y/%m/%d %H:%M:%S") if evacuation_advisory.lifted_at.present?
      when "4" # 不明
        date = nil
      when "5" # 常設
        date = nil
      else
        date = nil
      end
      node_information.add_element("pcx_sh:DateTime").add_text("#{date}") if date.present?
      # 最大収容人数 不明の場合は要素を省略
#       node_information.add_element("pcx_sh:Capacity").add_text("#{evacuation_advisory.capacity}") if evacuation_advisory.capacity.present?
      # 避難所状況 "空き","混雑","定員一杯","不明"
#       node_information.add_element("pcx_sh:Status").add_text("#{CONST['status'][evacuation_advisory.status]}") if evacuation_advisory.status.present?
      
      # 子要素がすべてブランクの場合、親要素を生成しない
      if evacuation_advisory.head_count.present? || evacuation_advisory.head_count_voluntary.present? ||
        evacuation_advisory.households.present? || evacuation_advisory.households_voluntary.present?
        # 親要素の追加
        node_number_of = node_information.add_element("pcx_sh:NumberOf")
        # 避難人数 自主避難人数を含む。不明の場合は要素を省略。
        node_number_of.add_element("pcx_sh:HeadCount").add_text("#{evacuation_advisory.head_count}") if evacuation_advisory.head_count.present?
        # 避難人数（うち自主避難）不明の場合は要素を省略。
#         node_number_of.add_element("pcx_sh:HeadCountVoluntary").add_text("#{evacuation_advisory.head_count_voluntary}") if evacuation_advisory.head_count_voluntary.present?
        # 避難世帯数 自主避難人数を含む。不明の場合は要素を省略。
        node_number_of.add_element("pcx_sh:Households", {"pcx_sh:unit" => "世帯"}).add_text("#{evacuation_advisory.households}") if evacuation_advisory.households.present?
        # 避難世帯数（うち自主避難）
#         node_number_of.add_element("pcx_sh:HouseholdsVoluntary", {"pcx_sh:unit" => "世帯"}).add_text("#{evacuation_advisory.households_voluntary}") if evacuation_advisory.households_voluntary.present?
      end
      
      # 避難所状況確認日時
      node_information.add_element("pcx_sh:ChangedDateTime").add_text("#{evacuation_advisory.changed_at.strftime("%Y/%m/%d %H:%M:%S")}") if evacuation_advisory.changed_at.present?
    end
    
    issue = Issue.new
    issue.tracker_id = 2
    issue.project_id = project.id
    issue.subject    = "避難勧告･指示 #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}"
    issue.author_id  = User.current.id 
    e.to_s
    issue.xml_body   = doc.to_s
    issue.save!
    
    return issue
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
  def number_evacuation_advisory_code
    seq =  connection.select_value("select nextval('evacuation_code_seq')")
    self.identifier = "04202I#{format("%014d", seq)}"
  end

end

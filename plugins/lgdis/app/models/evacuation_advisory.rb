# encoding: utf-8
class EvacuationAdvisory < ActiveRecord::Base
  unloadable

  acts_as_paranoid
  
  belongs_to :project
  
  attr_accessible :disaster_code,:advisory_type,:sort_criteria,:issue_or_lift,:area,
                  :area_kana,:district,:issued_date,:issued_hm,:issued_hm,:changed_date,
                  :changed_hm,:lifted_date,:lifted_hm,:address,:category,:cause,
                  :staff_no,:full_name,:alias,:headline,:message,
                  :emergency_hq_needed_prefecture,:emergency_hq_needed_city,
                  :alert,:alerting_area,:siren_area,:evacuation_order,
                  :evacuate_from,:evacuate_to,:evacuation_steps_by_authorities,:remarks, 
                  :households,:head_count,
                  :as => :evacuation_advisory

#   attr_accessible :households,:head_count,
#                   :as => :count





  ##正の整数チェック用オプションハッシュ値
  POSITIVE_INTEGER = {:only_integer => true,
                      :greater_than_or_equal_to => 0,
                      :less_than_or_equal_to => 2147483647,
                      :allow_blank => true}.freeze
  
  ##コンスタント存在チェック用
  CONST = Constant::hash_for_table(self.table_name).freeze
  
  #Data base NOT-NULL項目validations
  validates :project, :presence => true
#:NoMethodError (undefined method `keys' for nil:NilClass):
  validates :disaster_code, :presence => true, 
                :length => {:maximum => 20}
  validates :advisory_type, :presence => true,
                :inclusion => {:in => CONST[:advisory_type.to_s].keys, :allow_blank => true}
  validates :sort_criteria, :presence => true,
                :inclusion => {:in => CONST[:sort_criteria.to_s].keys, :allow_blank => true}
  validates :issue_or_lift,
                :inclusion => {:in => CONST[:issue_or_lift.to_s].keys, :allow_blank => true}
  validates :area, :presence => true,
                :length => {:maximum => 100}
  validates :area_kana,
                :length => {:maximum => 100}  #, :presence => true,
  validates :district,
                :inclusion => {:in => CONST[:district.to_s].keys, :allow_blank => true}

  #日付チェック
  validates :issued_date,
                :custom_format => {:type => :date}
  validates :issued_date, :presence => true, :unless => "issued_hm.blank?"
  validates :issued_hm,
                :custom_format => {:type => :time}
  validates :issued_hm, :presence => true, :unless => "issued_date.blank?"

  validates :changed_date,
                :custom_format => {:type => :date}
  validates :changed_date, :presence => true, :unless => "changed_hm.blank?"
  validates :changed_hm,
                :custom_format => {:type => :time}
  validates :changed_hm, :presence => true, :unless => "changed_date.blank?"

  validates :lifted_date,
                :custom_format => {:type => :date}
  validates :lifted_date, :presence => true, :unless => "lifted_hm.blank?"
  validates :lifted_hm,
                :custom_format => {:type => :time}
  validates :lifted_hm, :presence => true, :unless => "lifted_date.blank?"

  #そのほかの項目チェック:DB定義順
  validates :project, :presence => true
  validates :households,
                 :numericality => POSITIVE_INTEGER
  validates :head_count,
                 :numericality => POSITIVE_INTEGER
  validates :category,
                :inclusion => {:in => CONST[:category.to_s].keys, :allow_blank => true}
  validates :cause,
                :length => {:maximum => 4000} 
  validates :staff_no,
                :length => {:maximum => 10}
  validates :full_name,
                :length => {:maximum => 100}
  validates :alias,
                :length => {:maximum => 100}
  validates :headline,
                :length => {:maximum => 100}
  validates :message,
                :length => {:maximum => 4000}
  validates :emergency_hq_needed_prefecture,
                :length => {:maximum => 100}
  validates :emergency_hq_needed_city,
                :length => {:maximum => 100}
  validates :alert,
                :length => {:maximum => 4000}
  validates :alerting_area,
                :length => {:maximum => 4000}
  validates :siren_area,
                :length => {:maximum => 4000}
  validates :evacuation_order,
                :length => {:maximum => 4000}
  validates :evacuate_from,
                :length => {:maximum => 4000}
  validates :evacuate_to,
                :length => {:maximum => 4000}
  validates :evacuate_to,
                :length => {:maximum => 4000}
  validates :evacuation_steps_by_authorities,
                :length => {:maximum => 4000}
  validates :remarks,
                 :length => {:maximum => 4000}

  before_create :number_evacuation_advisory_code #, :if => Proc.new { |evacuation_advisory| evacuation_advisory.identifier.nil? }
  



















  
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
  
  # 
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
  
  attr_accessor_separate_datetime :issued_at,:lifted_at,:changed_at
  
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
  
  # 
  # Applic用チケット登録処理
  # ==== Args
  # _project_ :: Projectオブジェクト
  # ==== Return
  # Issueオブジェクト
  # ==== Raise
  def self.create_applic_issue(project)
    doc =  REXML::Document.new
    doc << REXML::XMLDecl.new('1.0', 'UTF-8')
    doc.add_element("_避難勧告･指示") # Root
    
    # 避難所を取得しXMLを生成する
#     evacuation_advisories = EvacuationAdvisory.all
    #Projectに紐付く避難勧告･指示を取得しXMLを生成する
    evacuation_advisories = EvacuationAdvisory.where(:project_id => project.id)
    
    evacuation_advisories.each do |eva|
      node_eva = doc.root.add_element("_避難勧告･指示情報")
      
      node_eva.add_element("避難勧告_指示識別情報").add_text("#{eva.identifier}")
      node_eva.add_element("災害名").add_text("#{eva.project.name}")
      node_eva.add_element("都道府県").add_text("")
      node_eva.add_element("市町村_消防本部名").add_text("")
      
      node_manager = node_eva.add_element("管理者")
      node_manager.add_element("職員番号").add_text("#{eva.staff_no}")
      node_name = node_manager.add_element("氏名")
      node_name.add_element("外字氏名").add_text("")
      
      node_issued = node_eva.add_element("発令日時")
      node_issued_date = node_issued.add_element("日付")
      node_issued_date.add_element("年").add_text("#{eva.issued_at.try(:year)}")
      node_issued_date.add_element("月").add_text("#{eva.issued_at.try(:month)}")
      node_issued_date.add_element("日").add_text("#{eva.issued_at.try(:day)}")
      node_issued.add_element("時").add_text("#{eva.issued_at.try(:hour)}")
      node_issued.add_element("分").add_text("#{eva.issued_at.try(:min)}")
      node_issued.add_element("秒").add_text("#{eva.issued_at.try(:sec)}")
      
      node_change = node_eva.add_element("移行日時")
      node_change_date = node_change.add_element("日付")
      node_change_date.add_element("年").add_text("#{eva.changed_at.try(:year)}")
      node_change_date.add_element("月").add_text("#{eva.changed_at.try(:month)}")
      node_change_date.add_element("日").add_text("#{eva.changed_at.try(:day)}")
      node_change.add_element("時").add_text("#{eva.changed_at.try(:hour)}")
      node_change.add_element("分").add_text("#{eva.changed_at.try(:min)}")
      node_change.add_element("秒").add_text("#{eva.changed_at.try(:sec)}")
      node_lifted = node_eva.add_element("解除日時")
      node_lifted_date = node_lifted.add_element("日付")
      node_lifted_date.add_element("年").add_text("#{eva.lifted_at.try(:year)}")
      node_lifted_date.add_element("月").add_text("#{eva.lifted_at.try(:month)}")
      node_lifted_date.add_element("日").add_text("#{eva.lifted_at.try(:day)}")
      node_lifted.add_element("時").add_text("#{eva.lifted_at.try(:hour)}")
      node_lifted.add_element("分").add_text("#{eva.lifted_at.try(:min)}")
      node_lifted.add_element("秒").add_text("#{eva.lifted_at.try(:sec)}")
      
      node_eva.add_element("対象人数").add_text("#{eva.head_count}")
      node_eva.add_element("対象世帯数").add_text("#{eva.households}")
      
      node_eva.add_element("備考").add_text("#{eva.remarks}")
    end
    
                          
    issue = Issue.new
    issue.tracker_id = 30
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
    file = File.new("#{Rails.root}/plugins/lgdis/files/xml/commons_evacuation.xml")
    # Xmlドキュメントの生成
    doc  = REXML::Document.new(file)
    
    # Projectに紐付く避難勧告･指示を取得しXMLを生成する
    #林版にあわせて以下の行をコメントアウトすべきか
    evas = EvacuationAdvisory.where(:project_id => project.id)

    # 避難人数、避難世帯数の集計値および避難勧告･指示件数の取得
     summary  = evas.select("SUM(head_count) AS head_count_sum, SUM(households) AS households_sum, COUNT(*) AS count").first
    # EvacuationAdvisory要素の取得
    node_evas = doc.elements["edxlde:EDXLDistribution/commons:contentObject/edxlde:xmlContent/edxlde:embeddedXMLContent/Report/pcx_ev:EvacuationOrder"]
    
    node_header = node_evas.add_element("pcx_eb:Disaster")
      node_header.add_element("pcx_eb:DisasterName").add_text("#{project.name}") if project.name.present?  #.add_text("#{summary.}") if summary..present?
    node_evas.add_element("pcx_ev:ComplementaryInfo"). if evas[0].present? 
    #node_evas.add_element("pcx_ev:ComplementaryInfo").add_text("避難勧告･指示一覧") if evas[0].present? 
    # 避難勧告指示の総数
    if summary.head_count_sum.present? || summary.households_sum.present? 
      node_total_number = node_evas.add_element("pcx_ev:TotalNumber")
        # 総世帯数
        node_total_number.add_element("pcx_ev:Households", {"pcx_ev:unit" => "世帯"}).add_text("#{summary.households_sum}") if summary.households_sum.present?
        # 避難総人数 自主避難人数を含む。
        node_total_number.add_element("pcx_ev:HeadCount").add_text("#{summary.head_count_sum}") if summary.head_count_sum.present?
    end
    
#     EvacuationAdvisory.all.each do |eva|
    evas.each do |eva|
      node_detail = node_evas.add_element("pcx_ev:Detail")
        # 発令区分
        node_detail.add_element("pcx_ev:Sort").add_text(CONST["sort_criteria"]["#{eva.sort_criteria}"]) if eva.sort_criteria.present?
        # 発令･解除区分
        node_detail.add_element("pcx_ev:IssueOrLift").add_text(CONST["issue_or_lift"]["#{eva.issue_or_lift}"]) if eva.issue_or_lift.present?
        node_obj = node_detail.add_element("pcx_ev:Object")
          node_obj.add_element("pcx_ev:Households", {"pcx_ev:unit" => "世帯"}).add_text("#{eva.households}") #if eva.households_subtotal.present?
          node_obj.add_element("pcx_ev:HeadCount").add_text("#{eva.head_count}") #if eva.head_count_subtotal.present?
        node_areas = node_detail.add_element("pcx_ev:Areas")
        node_area  = node_areas.add_element("pcx_ev:Area")
          node_location = node_area.add_element("pcx_eb:Location")
        # 発令・解除地区名称
            node_location.add_element("commons:areaName").add_text("#{eva.area}") if eva.area.present?
            node_location.add_element("commons:areaNameKana").add_text("#{eva.area_kana}") if eva.area_kana.present?
          # 日時
          case eva.issue_or_lift
          when "1" # 発令
            date = eva.issued_at.xmlschema if eva.issued_at.present?
          when "0" # 解除
            date = eva.lifted_at.xmlschema if eva.lifted_at.present?
          else
            date = nil
          end
          node_area.add_element("pcx_ev:DateTime").add_text("#{Time.now.xmlschema}") if date.present?
      
          node_obj = node_area.add_element("pcx_ev:Object")
            # 対象人数と対象世帯数 自主避難人数を含む。不明の場合は要素を省略。
            node_obj.add_element("pcx_ev:Households", {"pcx_ev:unit" => "世帯"}).add_text("#{eva.households}") if eva.households.present?
            node_obj.add_element("pcx_ev:HeadCount").add_text("#{eva.head_count}") if eva.head_count.present?
      
    end
    
    issue = Issue.new
    issue.tracker_id = 1
    issue.project_id = project.id
    issue.subject    = "避難勧告･指示 #{Time.now.xmlschema}"
    issue.author_id  = User.current.id 
    issue.xml_body   = doc.to_s
    issue.save!
    
    return issue
  end


























  # 避難勧告･指示情報初期登録処理→ShelterモデルをProject配下から独立する仕様にもとづき
  # メソッドはありません｡
  #   def self.import_initial_data(project)
  #   end

  # 全データ公開処理を行います。
  # cacheデータと、JSONファイルを上書きします。
  # ==== Args
  # ==== Return
  # ==== Raise
  def self.release_all_data
    write_cache
    create_json_file
  end
  
  # cacheデータを上書きします。
  # ==== Args
  # _shelters_ :: Shelterオブジェクト配列
  # ==== Return
  # ==== Raise
  def self.write_cache
    h = {}
    Shelter.all.each do |s|
      h[s.shelter_code] = {"name" => s.name, "area" => s.area}
    end
#     Rails.cache.write("shelter", h)
  end
  
  # JSONファイルを上書きします。
  # ==== Args
  # _shelters_ :: Shelterオブジェクト配列
  # ==== Return
  # ==== Raise
  def self.create_json_file
    h = {}
    Shelter.all.each do |s|
      h[s.shelter_code] = s.name
    end
    File.open(File.join(Rails.root,"public","shelter.json"), "w:utf-8") do |f|
      f.write(JSON.generate(h))
    end
  end
  
  # 全データ公開処理を呼び出します。（コールバック向け）
  # ==== Args
  # ==== Return
  # ==== Raise
  def execute_release_all_data
    self.class.release_all_data
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
  
  # 避難勧告･指示識別番号を設定します。
  # ==== Args
  # ==== Return
  # ==== Raise
  def number_evacuation_advisory_code
    seq =  connection.select_value("select nextval('evacuation_code_seq')")
    self.identifier = "04202E#{format("%014d", seq)}"
  end

end

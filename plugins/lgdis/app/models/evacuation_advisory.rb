# encoding: utf-8
class EvacuationAdvisory < ActiveRecord::Base
  unloadable

  attr_accessible :advisory_type,:sort_criteria,:issueorlift,:area,
                  :area_kana,:district,:issued_date,:issued_hm,:issued_hm,:changed_date,
                  :changed_hm,:lifted_date,:lifted_hm,:address,:category,:cause,
                  :staff_no,:full_name,:alias,:headline,:message,
                  :emergency_hq_needed_prefecture,:emergency_hq_needed_city,
                  :alert,:alerting_area,:siren_area,:evacuation_order,
                  :evacuate_from,:evacuate_to,:evacuation_steps_by_authorities,:remarks, 
                  :households,:head_count

  ##正の整数チェック用オプションハッシュ値
  POSITIVE_INTEGER = {:only_integer => true,
                      :greater_than_or_equal_to => 0,
                      :less_than_or_equal_to => 2147483647,
                      :allow_blank => true}.freeze
  
  ##コンスタント存在チェック用
  CONST = Constant::hash_for_table(self.table_name).freeze

  acts_as_paranoid
  validates_as_paranoid

  acts_as_datetime_separable :issued_at,:lifted_at,:changed_at

  #Data base NOT-NULL項目validations
  validates :advisory_type, 
                :inclusion => {:in => CONST[:advisory_type.to_s].keys, :allow_blank => true}
  validates :sort_criteria, :presence => true,
                :inclusion => {:in => CONST[:sort_criteria.to_s].keys, :allow_blank => true}
  validates :issueorlift,
                :inclusion => {:in => CONST[:issueorlift.to_s].keys, :allow_blank => true}
  validates :area, :presence => true,
                :length => {:maximum => 100}
  validates_uniqueness_of_without_deleted :area

  #そのほかの項目チェック:DB定義順
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

  before_create :number_evacuation_advisory_code , :if => Proc.new { |evacuation_advisory| evacuation_advisory.identifier.nil? }
  
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
    doc =  REXML::Document.new
    doc << REXML::XMLDecl.new('1.0', 'UTF-8')
    doc.add_element("_避難勧告･指示") # Root
    
    #避難勧告･指示を取得しXMLを生成する
    evacuation_advisories = EvacuationAdvisory.all
    evacuation_advisories.each do |eva|
      node_eva = doc.root.add_element("_避難勧告･指示情報")
      node_eva.add_element("災害識別情報").add_text("#{project.disaster_code}")
      node_eva.add_element("災害名").add_text("#{project.name}")
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
    issue.subject    = "避難勧告･指示 #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}"
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
    # Xmlドキュメントの生成
    doc  = REXML::Document.new
    # Projectに紐付く避難勧告･指示を取得しXMLを生成する
    evas = EvacuationAdvisory.all

    # 避難人数、避難世帯数の集計値および避難勧告･指示件数の取得
     summary  = EvacuationAdvisory.select("SUM(head_count) AS head_count_sum, SUM(households) AS households_sum, COUNT(*) AS count").first

    # EvacuationAdvisory要素の取得
    node_evas = doc.add_element("pcx_ev:EvacuationOrder") 
    node_header = node_evas.add_element("pcx_eb:Disaster")
      node_header.add_element("pcx_eb:DisasterName").add_text("#{project.name}")
    node_evas.add_element("pcx_ev:ComplementaryInfo")
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
        node_detail.add_element("pcx_ev:IssueOrLift").add_text(CONST["issueorlift"]["#{eva.issueorlift}"]) if eva.issueorlift.present?
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
          case eva.issueorlift
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

  private
  
  # 避難勧告･指示識別番号を設定します。
  # ==== Args
  # ==== Return
  # ==== Raise
  def number_evacuation_advisory_code
    seq =  connection.select_value("select nextval('evacuation_code_seq')")
    self.identifier = "04202E#{format("%014d", seq)}"
  end

end

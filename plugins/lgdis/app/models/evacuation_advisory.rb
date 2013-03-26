# encoding: utf-8
class EvacuationAdvisory < ActiveRecord::Base
  unloadable

  attr_accessible :advisory_type,:sort_criteria,:issueorlift,:area,
                  :area_kana,:district,:issued_at,:changed_at,
                  :lifted_at,:address,:category,:cause,
                  :staff_no,:full_name,:alias,:headline,:message,
                  :emergency_hq_needed_prefecture,:emergency_hq_needed_city,
                  :alert,:alerting_area,:siren_area,:evacuation_order,
                  :evacuate_from,:evacuate_to,:evacuation_steps_by_authorities,:remarks, 
                  :households,:head_count,:section, :disaster_overview,
                  :current_sort_criteria, :previous_sort_criteria

  ##正の整数チェック用オプションハッシュ値
  POSITIVE_INTEGER = {:only_integer => true,
                      :greater_than_or_equal_to => 0,
                      :less_than_or_equal_to => 2147483647,
                      :allow_blank => true}.freeze
  
  ##コンスタント存在チェック用
  CONST = Constant::hash_for_table(self.table_name).freeze

  acts_as_paranoid
  validates_as_paranoid

  #Data base NOT-NULL項目validations
  validates :advisory_type, 
                :inclusion => {:in => CONST[:advisory_type.to_s].keys, :allow_blank => true}

  #そのほかの項目チェック:DB定義順
  validates :sort_criteria,
                :inclusion => {:in => CONST[:sort_criteria.to_s].keys, :allow_blank => true}
  validates :issueorlift,
                :inclusion => {:in => CONST[:issueorlift.to_s].keys, :allow_blank => true} ,
                :presence => true, :if => Proc.new {|evacuation_advisory| evacuation_advisory.sort_criteria.to_i > 1}
  validates :current_sort_criteria, :presence => true,
                :inclusion => {:in => CONST[:current_sort_criteria.to_s].keys, :allow_blank => true}
  
  validates :area, :presence => true,
                :length => {:maximum => 100}
  validates_uniqueness_of_without_deleted :area

  validates :issued_at,
                :custom_format => {:type => :datetime}
  validates :changed_at,
                :custom_format => {:type => :datetime}
  validates :lifted_at,
                :custom_format => {:type => :datetime}
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
  validates :disaster_overview,
                 :length => {:maximum => 4000}

  before_create :number_evacuation_advisory_code , :if => Proc.new { |evacuation_advisory| evacuation_advisory.identifier.nil? }
  
  # 発令・解除区分
  ISSUEORLIFT_ISSUE = "1" # 発令
  ISSUEORLIFT_LIFT  = "0" # 解除
  
  validates :issued_at, :presence => true, :if => "self.issueorlift == '#{ISSUEORLIFT_ISSUE}'"
  validates :lifted_at, :presence => true, :if => "self.issueorlift == '#{ISSUEORLIFT_LIFT}'"
  
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
#     issues << self.create_applic_issue(project)
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
    # 発令区分の遷移履歴を更新する
    evacuation_advisories = EvacuationAdvisory.all
    evacuation_advisories.each do |eva|
      eva.update_sort_criteria_history
    end

    # Xmlドキュメントの生成
    doc  = REXML::Document.new

    # XML出力対象をしぼって出力順にコレクションとして準備 
    # 明確に避難準備/避難勧告/避難指示/警戒区域として発令または解除された情報に限定
    evas=[]
    evas << EvacuationAdvisory.where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => '5')
    evas << EvacuationAdvisory.where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => '4')
    evas << EvacuationAdvisory.where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => '3')
    evas << EvacuationAdvisory.where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => '2')
    evas << EvacuationAdvisory.where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => '5')
    evas << EvacuationAdvisory.where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => '4')
    evas << EvacuationAdvisory.where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => '3')
    evas << EvacuationAdvisory.where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => '2')
    
    # XML出力対象が存在しない場合は例外を発生させる
    raise EvacuationAdvisoriesController::ParamsException if evas.flatten.blank?

    # EvacuationAdvisory要素の取得
    node_evas = doc.add_element("pcx_ev:EvacuationOrder",{"xmlns:pcx_ev" => 
      "http://xml.publiccommons.ne.jp/pcxml1/body/evacuation3"}).add_text('')
    node_header = node_evas.add_element("pcx_eb:Disaster")
      node_header.add_element("pcx_eb:DisasterName").add_text("#{project.name}")
    node_evas.add_element("pcx_ev:ComplementaryInfo")

    # 避難人数、避難世帯数の合計値処理
    summary = EvacuationAdvisory.select("SUM(households) as households_sum, SUM(head_count) as head_count_sum").where(:issueorlift => [ISSUEORLIFT_ISSUE,ISSUEORLIFT_LIFT]).where(:sort_criteria=> ['2','3','4','5']).first
    if summary.households_sum.present? || summary.head_count_sum.present?
      node_total_number = node_evas.add_element("pcx_ev:TotalNumber")
      # 総世帯数
      node_total_number.add_element("pcx_ev:Households", {"pcx_ev:unit" => "世帯"}).add_text("#{summary.households_sum}") if summary.households_sum.present?
      # 避難総人数 自主避難人数を含む。
      node_total_number.add_element("pcx_ev:HeadCount").add_text("#{summary.head_count_sum}") if summary.head_count_sum.present?
    end
    
    evas.each do |evas2|
      next if evas2.blank?
      node_detail = node_evas.add_element("pcx_ev:Detail")
      e20 = evas2[0]
      # 発令区分
      node_detail.add_element("pcx_ev:Sort").add_text(CONST["sort_criteria"]["#{e20.sort_criteria}"]) if e20.sort_criteria.present?
      # 発令･解除区分
      node_detail.add_element("pcx_ev:IssueOrLift").add_text(CONST["issueorlift"]["#{e20.issueorlift}"]) if e20.issueorlift.present?
      node_obj = node_detail.add_element("pcx_ev:Object")
        st = subtotal(e20.issueorlift , e20.sort_criteria)
        node_obj.add_element("pcx_ev:Households", {"pcx_ev:unit" => "世帯"}).add_text(st[0])
        node_obj.add_element("pcx_ev:HeadCount").add_text(st[1]) 
      node_areas = node_detail.add_element("pcx_ev:Areas")

      evas2.each do |eva|
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
          node_area.add_element("pcx_ev:DateTime").add_text(date.to_s) if date.present?
      
          node_obj = node_area.add_element("pcx_ev:Object")
            # 対象人数と対象世帯数 自主避難人数を含む。不明の場合は要素を省略。
            node_obj.add_element("pcx_ev:Households", {"pcx_ev:unit" => "世帯"}).add_text("#{eva.households}") if eva.households.present?
            node_obj.add_element("pcx_ev:HeadCount").add_text("#{eva.head_count}") if eva.head_count.present?
      end
    end
    
    issue = Issue.new
    issue.tracker_id = 1
    issue.project_id = project.id
    issue.subject    = "避難勧告･指示 #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}"
    issue.author_id  = User.current.id
    fmtdoc = "\n" + doc.to_s.gsub(/></,">\n<").gsub("<pcx_ev:De","\n\n<pcx_ev:De")
      fmtdoc = fmtdoc.gsub("<commons:areaName>","\n<commons:areaName>")
    issue.xml_body   = fmtdoc
    issue.save!
    
    return issue
  end

  # 避難勧告･指示識別番号を設定します。
  # ==== Args
  # ==== Return
  # ==== Raise
  def number_evacuation_advisory_code
    seq =  connection.select_value("select nextval('evacuation_code_seq')")
    self.identifier = "04202E#{format("%014d", seq)}"
  end

  # 発令区分の遷移履歴を更新する
  def update_sort_criteria_history
    # 公共コモンズ用の発令区分と発令解除区分を決定
    self.sort_criteria, self.issueorlift = EVACUATIONADVISORY_MAP["sort_criteria_map"][self.previous_sort_criteria || "1"][self.current_sort_criteria]
    # 更新前の発令区分を保存
    self.previous_sort_criteria = self.current_sort_criteria
    save!
  end

  private

  # 発令解除区分ごとの世帯数と対象人数の小計を求めて配列に代入
  # ==== Args
  # _str_digit_issueorlift_ :: 発令解除区分値文字列｡constants.rbで定義｡
  # ==== Return
  # _[tmp.issueorlift_hcsum, tmp.issueorlift_hhsum]_ :: 発令解除区分ごとの対象人数と世帯数 小計の配列
  # ==== Raise
  def self.subtotal(issueorlift, sort_criteria)
    subtotals =[]
    subtotals = connection.select_rows("
      select SUM(households), SUM(head_count) from evacuation_advisories 
      where issueorlift = '#{issueorlift}' AND sort_criteria = '#{sort_criteria}'
    ").first
    return subtotals
  end
  
end

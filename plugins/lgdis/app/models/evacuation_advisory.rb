# encoding: utf-8
require 'csv'
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
  acts_as_mode_switchable Project

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
  validates :area_kana,
                :length => {:maximum => 100}
  validates_uniqueness_of_without_deleted :area, :scope => :record_mode

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

  # 発令
  SORT_ISSUE_NONE   = "1" # 指示無し(解除含む)※この値以外は発令とみなす
  # 発令・解除区分
  ISSUEORLIFT_ISSUE = "1" # 発令
  ISSUEORLIFT_LIFT  = "0" # 解除
  # 避難勧告指示トラッカーID
  TRACKER_EVACUATION = 1
  SUBJECT_TITLE = "避難勧告・指示情報"

  validates :issued_at, :presence => true, :if => "self.issueorlift == '#{ISSUEORLIFT_ISSUE}'"
  validates :lifted_at, :presence => true, :if => Proc.new {|evacuation_advisory| evacuation_advisory.issueorlift == ISSUEORLIFT_LIFT && evacuation_advisory.current_sort_criteria == SORT_ISSUE_NONE}

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
  # _options_ :: チケット情報
  # ==== Return
  # Issueオブジェクト配列
  # ==== Raise
  def self.create_issues(project, options)
    issues = []
    ### 公共コモンズ用チケット登録
    issues << self.create_commons_issue(project, options)
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
    evacuation_advisories = EvacuationAdvisory.mode_in(project).all
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
    issue.subject    = SUBJECT_TITLE + " #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}"
    issue.author_id  = User.current.id
    issue.xml_body   = doc.to_s
    issue.save!

    return issue
  end
  # 公共コモンズ用チケット登録処理
  # ==== Args
  # _project_ :: Projectオブジェクト
  # _options_ :: チケット情報
  # ==== Return
  # Issueオブジェクト
  # ==== Raise
  def self.create_commons_issue(project, options)
    # Xmlドキュメントの生成
    doc  = REXML::Document.new

    # XML出力対象をしぼって出力順にコレクションとして準備
    # 明確に避難準備/避難勧告/避難指示/警戒区域として発令または解除された情報に限定
    big_area = EVACUATIONADVISORY_MAP["big_area"]

    issue_big_area = EvacuationAdvisory.mode_in(project).select("area").where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => ['2', '3', '4', '5']).where(:area => big_area)
    
    issue_middle_area = []
    unless issue_big_area.blank?
      issue_big_area.each do |barea|
        issue_middle_area << EVACUATIONADVISORY_MAP["middle_area"]["#{barea.area}"]
      end
      issue_middle_area.delete(nil)
    end
    
    evas=[]
    if issue_middle_area.flatten.blank?
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => '5')
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => '4')
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => '3')
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => '2')
    else
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => '5').where("area not in (?)", issue_middle_area.flatten)
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => '4').where("area not in (?)", issue_middle_area.flatten)
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => '3').where("area not in (?)", issue_middle_area.flatten)
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria => '2').where("area not in (?)", issue_middle_area.flatten)
    end
    
    lift_middle_area = EvacuationAdvisory.mode_in(project).select("area").where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => ['2', '3', '4', '5']).where("area not in (?)", big_area)
  	
	lift_big_area = []
	unless lift_middle_area.blank?
      lift_middle_area.each do |marea|
        i = 0
        while i < big_area.length
          if EVACUATIONADVISORY_MAP["middle_area"]["#{big_area[i]}"].present? &&
            EVACUATIONADVISORY_MAP["middle_area"]["#{big_area[i]}"].include?(marea.area)
            lift_big_area << big_area[i]
            break
          end
          i += 1
        end
      end
    end
    
    if lift_big_area.flatten.blank?
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => '5')
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => '4')
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => '3')
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => '2')
    else
      lift_big_area.uniq
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => '5').where("area not in (?)", lift_big_area.flatten)
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => '4').where("area not in (?)", lift_big_area.flatten)
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => '3').where("area not in (?)", lift_big_area.flatten)
      evas << EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_LIFT).where(:sort_criteria => '2').where("area not in (?)", lift_big_area.flatten)
    end

    # XML出力対象が存在しない場合は例外を発生させる
    raise EvacuationAdvisoriesController::ParamsException if evas.flatten.blank?

    # EvacuationAdvisory要素の取得
    node_evas = doc.add_element("pcx_ev:EvacuationOrder",{"xmlns:pcx_ev" =>
      "http://xml.publiccommons.ne.jp/pcxml1/body/evacuation3"}).add_text('')
    node_header = node_evas.add_element("pcx_eb:Disaster")
      node_header.add_element("pcx_eb:DisasterName").add_text("#{project.name}")
    node_evas.add_element("pcx_ev:ComplementaryInfo")

    # 避難人数、避難世帯数の合計値処理
    if issue_middle_area.flatten.blank?
      summary = EvacuationAdvisory.mode_in(project).select("SUM(households) as households_sum, SUM(head_count) as head_count_sum").where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria=> ['2','3','4','5']).first
    else
      summary = EvacuationAdvisory.mode_in(project).select("SUM(households) as households_sum, SUM(head_count) as head_count_sum").where(:issueorlift => ISSUEORLIFT_ISSUE).where(:sort_criteria=> ['2','3','4','5']).where("area not in (?)", issue_middle_area.flatten).first
    end

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
      if e20.issueorlift == ISSUEORLIFT_ISSUE
        node_obj = node_detail.add_element("pcx_ev:Object")
        if issue_middle_area.flatten.blank?
	      st = EvacuationAdvisory.mode_in(project).select("SUM(households) as households_sum, SUM(head_count) as head_count_sum").where(:issueorlift => e20.issueorlift).where(:sort_criteria=> e20.sort_criteria).first
	    else
	      st = EvacuationAdvisory.mode_in(project).select("SUM(households) as households_sum, SUM(head_count) as head_count_sum").where(:issueorlift => e20.issueorlift).where(:sort_criteria=> e20.sort_criteria).where("area not in (?)", issue_middle_area.flatten).first
	    end
        node_obj.add_element("pcx_ev:Households", {"pcx_ev:unit" => "世帯"}).add_text("#{st.households_sum}")  if st.households_sum.present?
        node_obj.add_element("pcx_ev:HeadCount").add_text("#{st.head_count_sum}") if summary.head_count_sum.present?
      end
      
      node_areas = node_detail.add_element("pcx_ev:Areas")
      evas2.each do |eva|
        node_area  = node_areas.add_element("pcx_ev:Area")
        node_location = node_area.add_element("pcx_eb:Location")
        # 発令・解除地区名称
        node_location.add_element("commons:areaName").add_text("#{eva.area}") if eva.area.present?
        node_location.add_element("commons:areaNameKana").add_text("#{eva.area_kana}") if eva.area_kana.present?
        # 日時
        case eva.issueorlift
        when ISSUEORLIFT_ISSUE # 発令
          date = eva.issued_at.xmlschema if eva.issued_at.present?
        when ISSUEORLIFT_LIFT # 解除
          date = eva.lifted_at.xmlschema if eva.lifted_at.present?
        else
          date = nil
        end
        node_area.add_element("pcx_ev:DateTime").add_text(date.to_s) if date.present?
        if eva.issueorlift == ISSUEORLIFT_ISSUE
          node_obj = node_area.add_element("pcx_ev:Object")
          # 対象人数と対象世帯数 自主避難人数を含む。不明の場合は要素を省略。
          node_obj.add_element("pcx_ev:Households", {"pcx_ev:unit" => "世帯"}).add_text("#{eva.households}") if eva.households.present?
          node_obj.add_element("pcx_ev:HeadCount").add_text("#{eva.head_count}") if eva.head_count.present?
        end
      end
    end

    issue = Issue.new
    issue.tracker_id = TRACKER_EVACUATION
    issue.project_id = project.id
    issue.subject    = SUBJECT_TITLE + " #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}"
    issue.mail_subject = SUBJECT_TITLE
    issue.author_id  = User.current.id
    fmtdoc = "\n" + doc.to_s.gsub(/></,">\n<").gsub("<pcx_ev:De","\n\n<pcx_ev:De")
      fmtdoc = fmtdoc.gsub("<commons:areaName>","\n<commons:areaName>")
    issue.xml_body   = fmtdoc
    # チケットにcsvファイルを添付する
    tf = create_csv(EvacuationAdvisory.mode_in(project).order(:identifier), SUBJECT_TITLE,
        [:area,:area_kana,:sort_criteria,:issued_at,:lifted_at,:households,:head_count,:issueorlift])
    issue.save_attachments(["file"=> tf, "description" => "全ての" + SUBJECT_TITLE + "CSVファイル ※チケット作成時点"])
    # 一時ファイルの削除
    tf.close(true)
    issue.description = l(:summary_evacuation_advisory) + "\n\n" + options[:description]
    issue.save!

    unless EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_ISSUE).exists?    
      eva_clear = EvacuationAdvisory.mode_in(project).where(:issueorlift => ISSUEORLIFT_LIFT)
      eva_clear.each do |eva|
        eva.sort_criteria = nil
        eva.issueorlift = nil
        eva.save!
      end
    end

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
  # ==== Args
  # _project_ :: Projectオブジェクト
  # ==== Return
  # [更新結果のselfの配列, 公共コモンズ用チケットの説明フィールドに入力する文言]
  # ==== Raise
  def self.update_sort_criteria_history(project)
    histories = []
    updated_selves = EvacuationAdvisory.mode_in(project).order("identifier ASC").scoped
    # 初期発令時に前回の解除が残っているデータをのsort_criteria等を初期化するためのカウントをとる。
    #ec = EvacuationAdvisory.mode_in(project).select("COUNT(*) as eva_count").where(:deleted_at => nil).first
    #ic = EvacuationAdvisory.mode_in(project).select("COUNT(*) as issue_count").where("issueorlift = '#{ISSUEORLIFT_LIFT}' or issueorlift is null").where(:deleted_at => nil).first
    prev_delivery_time = connection.select_value("select max(d.updated_at) from delivery_histories d, issues i
                                              where d.issue_id = i.id and d.project_id = #{project.id} and i.tracker_id = #{TRACKER_EVACUATION} and d.delivery_place_id = 1 and d.status = 'done'")
    if prev_delivery_time.nil?
      prev_delivery_time = Time.now
    else
      prev_delivery_time = Time.parse(prev_delivery_time)
    end
    delivery_time = Time.now  - (EVACUATIONADVISORY_MAP["lift_term"].to_i * 3600)
    updated_selves.each do |eva|
      # 解除を発令してから数時間、発令解除区分の更新を回避する
      #if eva.current_sort_criteria == SORT_ISSUE_NONE && eva.issueorlift == ISSUEORLIFT_LIFT && delivery_time < prev_delivery_time && ec.eva_count != ic.issue_count
      if eva.current_sort_criteria == SORT_ISSUE_NONE && eva.issueorlift == ISSUEORLIFT_LIFT && delivery_time < prev_delivery_time
        histories << eva.get_sort_criteria_changes
      else
	    # 公共コモンズ用の発令区分と発令解除区分を決定
        eva.sort_criteria, eva.issueorlift = EVACUATIONADVISORY_MAP["sort_criteria_map"][eva.previous_sort_criteria || SORT_ISSUE_NONE][eva.current_sort_criteria]
        # 後続処理で登録するチケットの説明文を作成
        histories << eva.get_sort_criteria_changes
        # 更新前の発令区分を保存
        eva.previous_sort_criteria = eva.current_sort_criteria
        eva.save
      end
    end
    return updated_selves, histories.compact.join("\n")
  end

  # 発令区分の遷移文言を作成
  # ==== Args
  # ==== Return
  # 公共コモンズ用チケットの説明フィールドに入力する文言(1件分;textile形式)
  # ただし出力対象外の場合はnil
  # ==== Raise
  def get_sort_criteria_changes
    result = nil
    if previous_sort_criteria && previous_sort_criteria != SORT_ISSUE_NONE && previous_sort_criteria == current_sort_criteria && issueorlift == ISSUEORLIFT_ISSUE
      result = [area, CONST["sort_criteria"][sort_criteria], "継続"]
    else
      result = [area, CONST["sort_criteria"][sort_criteria], CONST["issueorlift"][issueorlift]]
    end
    return result.all? ? "|#{result.join("|")}|" : nil
  end

  private

  # 発令解除区分ごとの世帯数と対象人数の小計を求めて配列に代入
  # ==== Args
  # _issueorlift_ :: 集計対象とする発令区分
  # _sort_criteria_ :: 集計対象とする発令・解除区分
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

# encoding: utf-8
require_dependency 'issue'

module Lgdis
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        unloadable
        has_many :issues_additional_data, :class_name => 'IssuesAddtionDatum'


        validates :xml_control_status, :length => {:maximum => 12}
        validates :xml_control_editorialoffice, :length => {:maximum => 50}
        validates :xml_control_publishingoffice, :length => {:maximum => 100}
        validates :xml_control_cause, :length => {:maximum => 1}
        validates :xml_control_apply, :length => {:maximum => 1}
        validates :xml_head_title, :length => {:maximum => 100}
        validates :xml_head_targetdtdubious, :length => {:maximum => 8}
        validates :xml_head_targetduration, :length => {:maximum => 30}
        validates :xml_head_eventid, :length => {:maximum => 64}
        validates :xml_head_infotype, :length => {:maximum => 8}
        validates :xml_head_serial, :length => {:maximum => 8}
        validates :xml_head_infokind, :length => {:maximum => 100}
        validates :xml_head_infokindversion, :length => {:maximum => 12}
        validates :xml_head_text, :length => {:maximum => 500}
        
        safe_attributes 'xml_control_status',
          'xml_control',
          'xml_control_status',
          'xml_control_editorialoffice',
          'xml_control_publishingoffice',
          'xml_control_cause',
          'xml_control_apply',
          'xml_head',
          'xml_head_title',
          'xml_head_reportdatetime',
          'xml_head_targetdatetime',
          'xml_head_targetdtdubious',
          'xml_head_targetduration',
          'xml_head_validdatetime',
          'xml_head_eventid',
          'xml_head_infotype',
          'xml_head_serial',
          'xml_head_infokind',
          'xml_head_infokindversion',
          'xml_head_text',
          'xml_body',
          :if => lambda {|issue, user| issue.new_record? || user.allowed_to?(:edit_issues, issue.project) }
          
        # Applic用チケット編集処理
        # ==== Args
        # _project_ :: Projectオブジェクト
        # ==== Return
        # Issueオブジェクト
        # ==== Raise
        def exec_insert_applic(project)
          doc =  REXML::Document.new
          doc << REXML::XMLDecl.new('1.0', 'UTF-8')
          doc.add_element("_避難所") # Root
          
          # Projectに紐付く避難所を取得しXMLを生成する
          @shelters = Shelter.where(:project_id => project.id)
          # テキスト表示用にコンスタントテーブル取得
          @shelter_const = Constant::hash_for_table(Shelter.table_name)
          
          @shelters.each do |shelter|
            node_shelter = doc.root.add_element("_避難所情報")
            
            node_shelter.add_element("災害識別情報").add_text("#{shelter.disaster_code}")
            node_shelter.add_element("災害名").add_text("#{shelter.project.name}")
            node_shelter.add_element("都道府県").add_text("")
            node_shelter.add_element("市町村_消防本部名").add_text("")
            node_shelter.add_element("避難所識別情報").add_text("#{shelter.shelter_code}")
            node_shelter.add_element("避難所名").add_text("#{shelter.name}")
            node_shelter.add_element("電話番号").add_text("#{shelter.phone}")
            node_shelter.add_element("FAX番号").add_text("#{shelter.fax}")
            
            node_manager = node_shelter.add_element("管理者")
            node_manager.add_element("職員番号").add_text("#{shelter.manager_code}")
            node_name = node_manager.add_element("氏名")
            node_name.add_element("外字氏名").add_text("")
            node_name.add_element("内字氏名").add_text("#{shelter.manager_name}")
            node_name.add_element("フリガナ").add_text("")
            node_staff = node_manager.add_element("職員別名称")
            node_staff.add_element("外字氏名").add_text("")
            node_staff.add_element("内字氏名").add_text("")
            node_staff.add_element("フリガナ").add_text("")
            
            node_shelter.add_element("収容人数").add_text("#{shelter.capacity}")
            
            node_report = node_shelter.add_element("報告日時")
            node_report_date = node_report.add_element("日付")
            node_report_date.add_element("年").add_text("#{shelter.reported_at.try(:year)}")
            node_report_date.add_element("月").add_text("#{shelter.reported_at.try(:month)}")
            node_report_date.add_element("日").add_text("#{shelter.reported_at.try(:day)}")
            node_report.add_element("時").add_text("#{shelter.reported_at.try(:hour)}")
            node_report.add_element("分").add_text("#{shelter.reported_at.try(:min)}")
            node_report.add_element("秒").add_text("#{shelter.reported_at.try(:sec)}")
            
            node_shelter.add_element("建物被害状況").add_text("#{shelter.building_damage_info}")
            node_shelter.add_element("電力被害状況").add_text("#{shelter.electric_infra_damage_info}")
            node_shelter.add_element("通信手段被害状況").add_text("#{shelter.communication_infra_damage_info}")
            node_shelter.add_element("その他の被害").add_text("#{shelter.other_damage_info}")
            node_shelter.add_element("使用可否").add_text("#{@shelter_const['usable_flag'][shelter.usable_flag]}")
            node_shelter.add_element("開設の可否").add_text("#{@shelter_const['openable_flag'][shelter.openable_flag]}")
            
            node_opened = node_shelter.add_element("開設日時")
            node_opened_date = node_opened.add_element("日付")
            node_opened_date.add_element("年").add_text("#{shelter.opened_at.try(:year)}")
            node_opened_date.add_element("月").add_text("#{shelter.opened_at.try(:month)}")
            node_opened_date.add_element("日").add_text("#{shelter.opened_at.try(:day)}")
            node_opened.add_element("時").add_text("#{shelter.opened_at.try(:hour)}")
            node_opened.add_element("分").add_text("#{shelter.opened_at.try(:min)}")
            node_opened.add_element("秒").add_text("#{shelter.opened_at.try(:sec)}")
            
            node_closed = node_shelter.add_element("閉鎖日時")
            node_closed_date = node_closed.add_element("日付")
            node_closed_date.add_element("年").add_text("#{shelter.closed_at.try(:year)}")
            node_closed_date.add_element("月").add_text("#{shelter.closed_at.try(:month)}")
            node_closed_date.add_element("日").add_text("#{shelter.closed_at.try(:day)}")
            node_closed.add_element("時").add_text("#{shelter.closed_at.try(:hour)}")
            node_closed.add_element("分").add_text("#{shelter.closed_at.try(:min)}")
            node_closed.add_element("秒").add_text("#{shelter.closed_at.try(:sec)}")
            
            node_shelter.add_element("避難者数").add_text("#{shelter.head_count}")
            node_shelter.add_element("避難世帯数").add_text("#{shelter.households}")
            node_shelter.add_element("負傷者数").add_text("#{shelter.injury_count}")
            
            node_aid = node_shelter.add_element("要援護者数")
            node_aid.add_element("要介護度3以上").add_text("#{shelter.upper_care_level_three_count}")
            node_aid.add_element("一人暮らし高齢者_65歳以上").add_text("#{shelter.elderly_alone_count}")
            node_aid.add_element("高齢者世帯_夫婦共に65歳以上").add_text("#{shelter.elderly_couple_count}")
            node_aid.add_element("寝たきり高齢者").add_text("#{shelter.bedridden_elderly_count}")
            node_aid.add_element("認知症高齢者").add_text("#{shelter.elderly_dementia_count}")
            node_aid.add_element("療育手帳A_A1_A2所持者").add_text("#{shelter.rehabilitation_certificate_count}")
            node_aid.add_element("身体障がい者手帳1_2級所持者").add_text("#{shelter.physical_disability_certificate_count}")
            
            node_shelter.add_element("備考").add_text("#{shelter.note}")
          end
          
          self.tracker_id = 31
          self.project_id = project.id
          self.subject    = "避難所情報 #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}"
          self.author_id  = User.current.id
          self.xml_body   = doc.to_s
          
          return self
        end
        
        # 公共コモンズ用チケット編集処理
        # ==== Args
        # _project_ :: Projectオブジェクト
        # ==== Return
        # Issueオブジェクト
        # ==== Raise
        def exec_insert_commons(project)
          # テンプレートの読み込み
          file = File.new("#{Rails.root}/plugins/lgdis/files/xml/commons.xml")
          # Xmlドキュメントの生成
          doc  = REXML::Document.new(file)
          
          # Projectに紐付く避難所を取得しXMLを生成する
          @shelters = Shelter.where(:project_id => project.id)
          # 避難人数、避難世帯数の集計値および避難所件数の取得
          @summary  = @shelters.select("SUM(head_count) AS head_count_sum, SUM(head_count_voluntary) AS head_count_voluntary_sum,
            SUM(households) AS households_sum, SUM(households_voluntary) AS households_voluntary_sum, COUNT(*) AS count").first
          # テキスト表示用にコンスタントテーブル取得
          @shelter_const = Constant::hash_for_table(Shelter.table_name)
          
          # Shelter要素の取得
          node_shelter = doc.elements["edxlde:EDXLDistribution/commons:contentObject/edxlde:xmlContent/edxlde:embeddedXMLContent/Report/pcx_sh:Shelter"]
          
          # 子要素がすべてブランクの場合、親要素を生成しない
          if @summary.head_count_sum.present? || @summary.head_count_voluntary_sum.present? ||
            @summary.households_sum.present? || @summary.households_voluntary_sum.present?
            # 親要素の追加
            node_total_number = node_shelter.add_element("pcx_sh:TotalNumber")
            # 避難総人数 自主避難人数を含む。
            node_total_number.add_element("pcx_sh:HeadCount").add_text("#{@summary.head_count_sum}") if @summary.head_count_sum.present?
            # 避難総人数（うち自主避難）
            node_total_number.add_element("pcx_sh:HeadCountVoluntary").add_text("#{@summary.head_count_voluntary_sum}") if @summary.head_count_voluntary_sum.present?
            # 避難総世帯数
            node_total_number.add_element("pcx_sh:Households").add_text("#{@summary.households_sum}") if @summary.households_sum.present?
            # 避難総世帯数（うち自主避難）
            node_total_number.add_element("pcx_sh:HouseholdsVoluntary").add_text("#{@summary.households_voluntary_sum}") if @summary.households_voluntary_sum.present?
          end
          
          # 開設避難所数
          node_shelter.add_element("pcx_sh:TotalNumberOfShelter").add_text("#{@summary.count}") if @summary.count.present?
          # ループ構造の親要素追加
          node_informations = node_shelter.add_element("pcx_sh:Informations")
          
          @shelters.each do |shelter|
            node_information = node_informations.add_element("pcx_sh:Information")
            
            # 子要素がすべてブランクの場合、親要素を生成しない
            if shelter.name.present? || shelter.name_kana.present? ||
              shelter.phone.present? || shelter.address.present?
              # 親要素の追加
              node_location = node_information.add_element("pcx_sh:Location")
              # 所在地（緯度・経度）
              # node_location.add_element("edxlde:circle").add_text("")
              # 避難所名
              node_location.add_element("commons:areaName").add_text("#{shelter.name}") if shelter.name.present?
              # 避難所名ふりがな
              node_location.add_element("commons:areaNameKana").add_text("#{shelter.name_kana}") if shelter.name_kana.present?
              # 避難所連絡先
              node_location.add_element("pcx_eb:ContactInfo", {"pcx_eb:contactType" => "phone"}).add_text("#{shelter.phone}") if shelter.phone.present?
              # 所在地
              node_location.add_element("pcx_sh:Address").add_text("#{shelter.address}") if shelter.address.present?
            end
            
            # 避難所種別 "避難所","臨時避難所","広域避難場所","一時避難場所"
            node_information.add_element("pcx_sh:Type").add_text(@shelter_const["shelter_type"]["#{shelter.shelter_type}"]) if shelter.shelter_type.present?
            # 避難所区分 "未開設","開設","閉鎖","不明","常設"
            node_information.add_element("pcx_sh:Sort").add_text(@shelter_const["shelter_sort"]["#{shelter.shelter_sort}"]) if shelter.shelter_sort.present?
            
            # 開設・閉鎖日時
            case shelter.shelter_sort
            when "1" # 未開設
              date = nil
            when "2" # 開設
              date = shelter.opened_at.strftime("%Y/%m/%d %H:%M:%S") if shelter.opened_at.present?
            when "3" # 閉鎖
              date = shelter.closed_at.strftime("%Y/%m/%d %H:%M:%S") if shelter.closed_at.present?
            when "4" # 不明
              date = nil
            when "5" # 常設
              date = nil
            else
              date = nil
            end
            node_information.add_element("pcx_sh:DateTime").add_text("#{date}") if date.present?
            # 最大収容人数 不明の場合は要素を省略
            node_information.add_element("pcx_sh:Capacity").add_text("#{shelter.capacity}") if shelter.capacity.present?
            # 避難所状況 "空き","混雑","定員一杯","不明"
            node_information.add_element("pcx_sh:Status").add_text("#{@shelter_const['status'][shelter.status]}") if shelter.status.present?
            
            # 子要素がすべてブランクの場合、親要素を生成しない
            if shelter.head_count.present? || shelter.head_count_voluntary.present? ||
              shelter.households.present? || shelter.households_voluntary.present?
              # 親要素の追加
              node_number_of = node_information.add_element("pcx_sh:NumberOf")
              # 避難人数 自主避難人数を含む。不明の場合は要素を省略。
              node_number_of.add_element("pcx_sh:HeadCount").add_text("#{shelter.head_count}") if shelter.head_count.present?
              # 避難人数（うち自主避難）不明の場合は要素を省略。
              node_number_of.add_element("pcx_sh:HeadCountVoluntary").add_text("#{shelter.head_count_voluntary}") if shelter.head_count_voluntary.present?
              # 避難世帯数 自主避難人数を含む。不明の場合は要素を省略。
              node_number_of.add_element("pcx_sh:Households", {"pcx_sh:unit" => "世帯"}).add_text("#{shelter.households}") if shelter.households.present?
              # 避難世帯数（うち自主避難）
              node_number_of.add_element("pcx_sh:HouseholdsVoluntary", {"pcx_sh:unit" => "世帯"}).add_text("#{shelter.households_voluntary}") if shelter.households_voluntary.present?
            end
            
            # 避難所状況確認日時
            node_information.add_element("pcx_sh:CheckedDateTime").add_text("#{shelter.checked_at.strftime("%Y/%m/%d %H:%M:%S")}") if shelter.checked_at.present?
          end
          
          self.tracker_id = 2
          self.project_id = project.id
          self.subject    = "避難所情報 #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}"
          self.author_id  = User.current.id
          self.xml_body   = doc.to_s
          
          return self
        end
        
        # CustomValue作成処理
        # Issueに紐付くCustomFieldのCustomValueを作成する
        # ==== Args
        # ==== Return
        # ==== Raise
        def create_custom_value
          self.tracker.custom_fields.each do |custom_field|
            CustomValue.create!(:customized_type => self.class.to_s, 
              :customized_id => self.id, :custom_field_id => custom_field.id)
          end
        end
      end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
    end
  end
end

Issue.send(:include, Lgdis::IssuePatch)

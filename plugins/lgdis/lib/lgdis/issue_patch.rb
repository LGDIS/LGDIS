# encoding: utf-8
require_dependency 'issue'
require "#{Rails.root}/plugins/lgdis/app/models/constant"

module Lgdis
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        has_many :issue_geographies, :dependent => :destroy
        has_many :delivery_histories

        acts_as_datetime_separable :published_at, :opened_at, :closed_at

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
          'mail_subject',
          'summary',
          'type_update',
          'description_cancel',
          'published_date',
          'published_hm',
          'delivered_area',
          'opened_date',
          'opened_hm',
          'closed_date',
          'closed_hm',
          :if => lambda {|issue, user| issue.new_record? || user.allowed_to?(:edit_issues, issue.project) }

        alias_method_chain :copy_from, :geographies
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      # 更新種別
      TYPE_UPDATE = { '1' => 'Report',
                      '2' => 'Update',
                      '3' => 'Cancel'
                    }.freeze

      CONST = Constant.hash_for_table(Issue.table_name).freeze

      # チケット情報のコピー
      # チケット位置情報もコピーするように処理追加
      # ==== Args
      # ==== Return
      # ==== Raise
      def copy_from_with_geographies(arg, options={})
        copy_from_without_geographies(arg, options)
        return self if !@copied_from || !@copied_from.issue_geographies
        @copied_from.issue_geographies.each do |copied_from_g|
          self.issue_geographies.build(copied_from_g.attributes.dup.except(:id, :issue_id, :created_at, :updated_at))
        end
        self
      end

      # 配信処理
      # ==== Args
      # _delivery_history_ :: DeliveryHistoryオブジェクト
      # _status_to_ :: 更新先ステータス
      # ==== Return
      # DeliveryHistoryオブジェクト
      # ==== Raise
      def deliver(delivery_history, status_to)
        begin
        if status_to == 'runtime'
          delivery_place_id = delivery_history.delivery_place_id
          summary = create_summary(delivery_place_id)
          delivery_job_class = eval(DST_LIST['delivery_place'][delivery_place_id]['delivery_job_class'])
          test_flag = DST_LIST['test_prj'][self.project_id]
          delivery_history.update_attribute(:status, 'runtime')
          Resque.enqueue(delivery_job_class, delivery_history.id, summary, test_flag)
          # アーカイブの為、チケットに登録
          msg = summary['message'].blank? ? summary : summary['message']
          journal = self.init_journal(User.current, msg)
          unless self.save
           # TODO
           # log 出力内容
           # Rails.logger.error
          end
        end
        rescue
          # TODO
          # log 出力
          p $!
          delivery_history.update_attribute(:status, 'failed')
        ensure
          
        end
        return delivery_history
      end

      # 配信内容作成処理
      # ==== Args
      # _delivery_place_id_ :: 外部配信先ID
      # ==== Return
      # 配信内容
      # ==== Raise
      def create_summary(delivery_place_id)
        return eval("self.#{DST_LIST['delivery_place'][delivery_place_id]['create_msg_method']}(delivery_place_id)")
      end

      # Twitter 用配信メッセージ作成処理
      # ==== Args
      # _delivery_place_id_ :: 外部配信先ID
      # ==== Return
      # 配信内容文字列
      # ==== Raise
      def create_twitter_msg(delivery_place_id)
        summary = self.add_url_and_training(self.summary, delivery_place_id)
        return summary
      end

      # Facebook 用配信メッセージ作成処理
      # ==== Args
      # _delivery_place_id_ :: 外部配信先ID
      # ==== Return
      # 配信内容文字列
      # ==== Raise
      def create_facebook_msg(delivery_place_id)
        summary = self.add_url_and_training(self.summary, delivery_place_id)
        return summary
      end

      # メール用 配信メッセージ作成処理
      # ==== Args
      # _delivery_place_id_ :: 外部配信先ID
      # ==== Return
      # 配信内容ハッシュ
      # ==== Raise
      def create_smtp_msg(delivery_place_id)
        summary = Hash.new
        # TODO:件名、本文が未決
        str = self.add_url_and_training(self.summary, delivery_place_id)

        raise "送信先アドレス設定がありません" unless to = DST_LIST['delivery_place'][delivery_place_id]['to']
        summary.store('mailing_list_name', to)
        summary.store('title', self.mail_subject)
        summary.store('message', str)
        return summary
      end

      # ATOM 用 配信メッセージ作成処理
      # ==== Args
      # _delivery_place_id_ :: 外部配信先ID
      # ==== Return
      # 配信内容
      # ==== Raise
      def create_atom_msg(delivery_place_id)
        # テンプレートの読み込み
        file = File.new("#{Rails.root}/plugins/lgdis/files/xml/atom_with_georss.xml")
        # Xmlドキュメントの生成
        doc  = REXML::Document.new(file)

        feed = doc.elements["feed"]
        feed.elements["title"].text = self.project.name

        #CGI off-line mode回避用ダミーコード:最後にコントロールDを入れる作業を回避
        ARGV.replace(%w(abc=001 def=002))
        cgi = CGI.new
        feed.elements["link"].attributes["href"] += "#{cgi.server_name}/r/feed/"

        time = Time.now
        feed.elements["updated"].text = time.xmlschema

        author = feed.elements["author"]
        author.elements["name"].text = self.author.name
        author.elements["email"].text = self.author.mail

        feed.elements["id"].text += UUIDTools::UUID.random_create.to_s

        entry = feed.elements["entry"]
        # TODO
        # コントロールプレーン部の対応で作成内容(参照情報)が
        # 変更になった可能性があり、確認必要
        # entry.elements["title"].text = "#{self.mail_subject}"
        # entry.elements["summary"].text = self.summary.to_s[0,140]
        entry.elements["title"].text = "#{self.tracker.name} ##{self.id}: #{self.subject}"
        entry.elements["id"].text += UUIDTools::UUID.random_create.to_s
        entry.elements["updated"].text = time.xmlschema
        entry.elements["summary"].text = self.description.to_s[0,140]

        cnt = 0
        self.points_for_map.each do |point|
          cnt += 1
          REXML::Comment.new("-------- 本件についての地理情報 No." + cnt.to_s + " --------", entry)
          entry.add_element("georss:point").text = point["points"].join(" ")
          entry.add_element("georss:relationshipTag").text = "iconfile=#{rand(16)}-dot.png"
        end

        self.lines_for_map.each do |line|
          cnt += 1
          REXML::Comment.new("-------- 本件についての地理情報 No." + cnt.to_s + " --------", entry)
          entry.add_element("georss:line").text = line["points"].flatten.join(" ")
          entry.add_element("georss:relationshipTag").text = "iconfile=#{rand(16)}-dot.png"
        end

        self.polygons_for_map.each do |polygon|
          cnt += 1
          REXML::Comment.new("-------- 本件についての地理情報 No." + cnt.to_s + " --------", entry)
          entry.add_element("georss:polygon").text = polygon["points"].flatten.join(" ")
          entry.add_element("georss:relationshipTag").text = "iconfile=#{rand(16)}-dot.png"
        end

        self.polygons_for_map.each do |polygon|
          cnt += 1
          REXML::Comment.new("-------- 本件についての地理情報 No." + cnt.to_s + " --------", entry)
          entry.add_element("georss:polygon").text = polygon["points"].flatten.join(" ")
          entry.add_element("georss:relationshipTag").text = "iconfile=#{rand(16)}-dot.png"
        end

        self.locations_for_map.each do |location|
          cnt += 1
          REXML::Comment.new("-------- 本件についての地理情報 No." + cnt.to_s + " --------", entry)
          entry.add_element("georss:featureTypeTag").text = location["locaton"]
          entry.add_element("georss:relationshipTag").text = "iconfile=#{rand(16)}-dot.png"
        end

        return doc.to_s
      end

      # 災害訓練,URL 追加処理
      # ==== Args
      # _contents_ :: コンテンツ文字列
      # _delivery_place_id_ :: 外部配信先ID
      # ==== Return
      # 引数のコンテンツ文字列に災害訓練、URLを追加した文字列
      # ==== Raise
      def add_url_and_training(contents, delivery_place_id)
        url = ''
        case DST_LIST['delivery_place'][delivery_place_id]['add_url_type']
        when 'disaster_portal'
          url = DST_LIST['disaster_portal_url']
        when 'lgdsf'
          url = DST_LIST['lgdsf_url']
        end

        # 災害訓練モード判定
        DST_LIST['training_prj'][self.project_id] ? \
          '【災害訓練】' + "\n" + url.to_s + "\n" + contents.to_s : url.to_s + "\n" + contents.to_s
      end

      # 公共コモンズ用XML 作成処理
      # Control部, Head部, Body部を結合し
      # 配信内容を作成
      # ==== Args
      # _delivery_place_id_ :: 外部配信先ID
      # ==== Return
      # _doc_ :: 配信内容
      # ==== Raise
      def create_commons_msg(delivery_place_id)
        # テンプレートの読み込み
        commons_xml = DST_LIST['commons_xml'][self.tracker_id]
        file = File.new("#{Rails.root}/plugins/lgdis/files/xml/#{commons_xml}")
        # Xmlドキュメントの生成
        doc  = REXML::Document.new(file)

        # XML Body 部作成
        # XML 生成時に名前空間を明示的に指定しないとエラーとなる為準備
        start_element = DST_LIST['commons_xml_field']['namespace_start_tag']
        end_element   = DST_LIST['commons_xml_field']['namespace_end_tag']

        if DST_LIST['ugent_mail_ids'].include? delivery_place_id
          xml_body = create_commmons_area_mail_body
          element  = 'pcx_um:UrgentMail'
        else
          xml_body = self.xml_body
          element  = DST_LIST['destination_xpath'][self.tracker_id]
        end
        xml_body = start_element + xml_body + end_element
        xml_body  = REXML::Document.new(xml_body).elements["//#{element}"]


        # tracker_id に紐付く標題を設定
        title  = DST_LIST['tracker_title'][self.tracker_id]

        # status(更新種別), uuid, edition_num(版番号)を設定
        edition_mng = EditionManagement.find_by_project_id_and_tracker_id(self.project_id, self.tracker_id)
        edition_fields_map = set_edition_mng_field(edition_mng)

        # 運用種別フラグ
        operation_flg = DST_LIST['commons_xml_field']['edxl_status'][self.project_id]
        operation_flg = operation_flg.blank? ? 'Actual' : operation_flg

        # 希望公開開始日時
        target_date = name_in_custom_field_value(DST_LIST['custom_field_delivery']['target_date'])
        target_time = name_in_custom_field_value(DST_LIST['custom_field_delivery']['target_time'])
        target_datetime = target_date.blank? || target_time.blank? ? nil : target_date + ' ' + target_time

        # 希望公開終了日時
        valid_date = name_in_custom_field_value(DST_LIST['custom_field_delivery']['valid_date'])
        valid_time = name_in_custom_field_value(DST_LIST['custom_field_delivery']['valid_time'])
        valid_datetime = valid_date.blank? || valid_time.blank? ? nil : valid_date + ' ' + valid_time

        # 更新種別設定処理
        type_update = TYPE_UPDATE[self.type_update]

        # 配信対象地域
        str=''
        self.delivered_area='1'
        self.delivered_area.split(',').each do |s|
          str << CONST['delivered_area'][s] + ','
        end
        delivered_area = str.split(//u)[0..-2].join

        # edxl 部要素追加
        doc.elements["//edxlde:distributionID"].add_text(edition_fields_map['uuid'])
        doc.elements["//edxlde:dateTimeSent"].add_text(Time.now.xmlschema)
        doc.elements["//edxlde:distributionStatus"].add_text(operation_flg)
        doc.elements["//edxlde:distributionType"].add_text(type_update)
        doc.elements["//edxlde:combinedConfidentiality"].add_text(DST_LIST['commons_xml_field']['confidential_message'])
        doc.elements["//commons:targetArea/commons:areaName"].add_text(delivered_area)
        doc.elements["//edxlde:contentDescription"].add_text(name_in_custom_field_value(DST_LIST['custom_field_delivery']['summary']))
        doc.elements["//edxlde:consumerRole/edxlde:valueListUrn"].add_text('publicCommons:media:urgentmail:carrier') if DST_LIST['ugent_mail_ids'].include? delivery_place_id # 緊急速報メールの場合のみ
        doc.elements["//edxlde:consumerRole/edxlde:value"].add_text(DST_LIST['commons_xml_field']['carrier'][delivery_place_id]) if DST_LIST['ugent_mail_ids'].include? delivery_place_id # 緊急速報メールの場合のみ

        # Control 部要素追加
        doc.elements["//edxlde:distributionStatus"].add_text(operation_flg)
        doc.elements["//EditorialOffice/pcx_eb:OfficeName"].add_text(DST_LIST['commons_xml_field']['editorial_office'])
        doc.elements["//PulishingOffice/pcx_eb:OfficeName"].add_text(DST_LIST['commons_xml_field']['pulishing_office'])
        doc.elements["//pcx_eb:contactType"].add_text(DST_LIST['contact_type']) unless DST_LIST['contact_type'].blank?
        doc.elements["//pcx_eb:Description"].add_text(name_in_custom_field_value(DST_LIST['custom_field_delivery']['corrected'])) if edition_fields_map['status'] == 0
        doc.elements["//pcx_eb:Datetime"].add_text(self.updated_on.xmlschema) if edition_fields_map['status'] == 0

        # Head 部要素追加
        doc.elements["//pcx_ib:Title"].add_text(I18n.t('target_municipality') + ' ' + self.project.name + ' ' +  (title.present? ? title : '緊急速報メール'))
        doc.elements["//pcx_ib:CreateDateTime"].add_text(self.created_on.xmlschema)
        doc.elements["//pcx_ib:FirstCreateDateTime"].add_text(self.created_on.xmlschema)
        doc.elements["//pcx_ib:ReportDateTime"].add_text(self.published_at)
        doc.elements["//pcx_ib:TargetDateTime"].add_text(target_datetime.to_datetime.xmlschema) unless target_datetime.blank?
        doc.elements["//pcx_ib:ValidDateTime"].add_text(valid_datetime.to_datetime.xmlschema) unless valid_datetime.blank?
        doc.elements["//edxlde:distributionID"].add_text(edition_fields_map['uuid'])
        doc.elements["//edxlde:distributionType"].add_text(type_update)
        doc.elements["//pcx_ib:Head/commons:documentRevision"].add_text("#{edition_fields_map['edition_num']}")
        doc.elements["//pcx_ib:Head/commons:documentID"].add_text(edition_fields_map['uuid'])
        doc.elements["//pcx_ib:Text"].add_text(name_in_custom_field_value(DST_LIST['custom_field_delivery']['summary']))
        doc.elements["//pcx_ib:Areas/pcx_ib:Area/commons:areaName"].add_text(DST_LIST['custom_field_delivery']['area_name'])

        # Body 部
        doc.elements["//pcx_ib:Head"].next_sibling = REXML::Element.new(xml_body.to_s)

        # Edxl 部要素追加
        doc.elements["//commons:publishingOfficeName"].add_text(DST_LIST['custom_field_delivery']['pulishing_office'])
        doc.elements["//commons:previousDocumentRevision"].add_text("#{edition_fields_map['edition_num']}")
        doc.elements["//commons:contentObject/commons:documentRevision"].add_text("#{edition_fields_map['edition_num']}")
        doc.elements["//commons:contentObject/commons:documentID"].add_text(edition_fields_map['uuid'])

        return doc.to_s
      end

      # map表示向けの場所（location）ハッシュ配列を返却します
      # ==== Args
      # ==== Return
      # map表示向けのハッシュ配列 ※空の場合は[]
      # * "location" :: 場所文字列
      # * "remarks" :: 備考
      # ==== Raise
      def locations_for_map
        locations = []
        self.issue_geographies.each do |ig|
          next if ig.location.blank?
          locations << ig.location_for_map
        end
        return locations
      end

      # map表示向けの経緯度（point）ハッシュ配列を返却します
      # ==== Args
      # _to_datum_ :: 必要な測地系 ※未指定の場合は世界測地系
      # ==== Return
      # map表示向けのハッシュ配列 ※空の場合は[]
      # * "points"  :: 座標
      # * "remarks" :: 備考
      # ==== Raise
      def points_for_map(to_datum = IssueGeography::DATUM_JGD)
        points = []
        self.issue_geographies.each do |ig|
          next if ig.point.blank?
          points << ig.point_for_map(to_datum)
        end
        return points
      end

      # map表示向けの線（line）ハッシュ配列を返却します
      # ==== Args
      # _to_datum_ :: 必要な測地系 ※未指定の場合は世界測地系
      # ==== Return
      # map表示向けのハッシュ配列 ※空の場合は[]
      # * "points"  :: 座標
      # * "remarks" :: 備考
      # ==== Raise
      def lines_for_map(to_datum = IssueGeography::DATUM_JGD)
        lines = []
        self.issue_geographies.each do |ig|
          next if ig.line.blank?
          lines << ig.line_for_map(to_datum)
        end
        return lines
      end

      # map表示向けの多角形（polygon）ハッシュ配列を返却します
      # ==== Args
      # _to_datum_ :: 必要な測地系 ※未指定の場合は世界測地系
      # ==== Return
      # map表示向けのハッシュ配列 ※空の場合は[]
      # * "points"  :: 座標
      # * "remarks" :: 備考
      # ==== Raise
      def polygons_for_map(to_datum = IssueGeography::DATUM_JGD)
        polygons = []
        self.issue_geographies.each do |ig|
          next if ig.polygon.blank?
          polygons << ig.polygon_for_map(to_datum)
        end
        return polygons
      end

      private

      # 公共コモンズ用XML 作成処理(エリアメールBody部)
      # ==== Args
      # ==== Return
      # ==== Raise
      def create_commmons_area_mail_body
        doc =  REXML::Document.new
        doc << REXML::XMLDecl.new('1.0', 'UTF-8')
        doc.add_element("pcx_um:UrgentMail").add_attribute("xmlns:pcx_um", "http://xml.publiccommons.ne.jp/pcxml1/body/UrgentMail3") # root
        doc.elements["//pcx_um:UrgentMail"].add_element("pcx_um:Information")

        doc.elements["//pcx_um:Information"].add_element("pcx_um:Title").add_text("#{self.mail_subject}")
        doc.elements["//pcx_um:Information"].add_element("pcx_um:Message").add_text("#{self.summary}")

        return doc
      end

      # 公共コモンズ用XML 作成処理(イベント・お知らせBody部)
      # ==== Args
      # ==== Return
      # _doc_ :: REXML::Document
      # ==== Raise
      def create_commmons_event_body
        doc =  REXML::Document.new
        doc << REXML::XMLDecl.new('1.0', 'UTF-8')
        doc.add_element("pcx_gi:GeneralInformation").add_attribute("xmlns:pcx_gi", "http://xml.publiccommons.ne.jp/pcxml1/body/GeneralInformation3") # root

        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:DisasterInformationType").add_text("#{CONST['type_update'][self.type_update]}")
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_eb:Disaster").add_element("pcx_eb:DisasterName").add_text("#{self.project.name}")
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:pcx_gi:Category").add_text("#{DST_LIST["tracker_grouping"][self.tracker_id][0]}")
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:pcx_gi:subCategory").add_text("#{DST_LIST["tracker_grouping"][self.tracker_id][1]}")
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:Title").add_text("#{self.mail_subject}")
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:Description").add_text("#{self.summary}")
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:URL").add_text("#{name_in_custom_field_value(37)}") # 関連するホームページ

        return doc
      end

      # 版番号管理テーブル用フィールド設定処理
      # UUID, 更新種別(status), 版番号(edition_num) を
      # ハッシュで返却します
      # ==== Args
      # ==== Return
      # ==== Raise
      def set_edition_mng_field(edition_mng)
        uuid        = edition_mng.blank? || edition_mng.status == 0 ? \
                      UUIDTools::UUID.random_create.to_s : edition_mng.uuid
        status      = edition_mng.blank? || edition_mng.status == 0 ? \
                      1 : edition_mng.status
        edition_num = edition_mng.blank? || edition_mng.status == 0 ? \
                      1 : edition_mng.edition_num + 1

        edition_field_map = Hash.new
        edition_field_map.store('uuid', uuid)
        edition_field_map.store('status', status)
        edition_field_map.store('edition_num', edition_num)

        return edition_field_map
      end
    end
  end
end

Issue.send(:include, Lgdis::IssuePatch)

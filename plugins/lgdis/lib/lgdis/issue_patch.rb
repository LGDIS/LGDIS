# encoding: utf-8
require_dependency 'issue'

module Lgdis
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        has_many :issue_geographies, :dependent => :destroy
        has_many :delivery_histories, :dependent => :destroy

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
        validates :published_at, :custom_format => {:type => :datetime}
        validates :opened_at, :custom_format => {:type => :datetime}
        validates :closed_at, :custom_format => {:type => :datetime}

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
          'published_at',
          'delivered_area',
          'opened_at',
          'closed_at',
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

      # 補足情報のcustom_field_id
      COMPLEMENTARYINFO_ID = 5
      # 関連するホームページのcustom_field_id
      URL_ID = 37
      # 緊急速報メール に紐付くtitle id
      # destination_list.yml tracker_title　に紐付くID
      UGENT_MAIL_ID = 0

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
            delivery_history.update_attributes({:status => status_to, :respond_user => User.current.login, :process_date => Time.now})
            Resque.enqueue(delivery_job_class, delivery_history.id, summary, test_flag)
            unless self.save
             # TODO
             # log 出力内容
             # Rails.logger.error
            end
          elsif status_to == 'reject'
            delivery_history.update_attributes({:status => status_to, :respond_user => User.current.login, :process_date => Time.now})
          end
        rescue
          # TODO
          # log 出力
          p $!
          status_to = 'failed'
          delivery_history.update_attribute(:status, status_to)
        ensure
          return status_to
        end
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

        self.locations_for_map.each do |location|
          cnt += 1
          REXML::Comment.new("-------- 本件についての地理情報 No." + cnt.to_s + " --------", entry)
          entry.add_element("georss:featureTypeTag").text = location["location"]
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
        if DST_LIST['email_deployed'][delivery_place_id].present?
          url = DST_LIST['lgdsf_url'] + '?' + Time.now.strftime("%Y%m%d%H%M%S")
        end

        # 災害訓練モード判定
        DST_LIST['training_prj'][self.project_id] ? \
          '【災害訓練】' + "\n" + DST_LIST['disaster_portal_url'] + "\n" + url.to_s + "\n" + contents.to_s : \
          DST_LIST['disaster_portal_url'] + "\n" + url.to_s + "\n" + contents.to_s
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
        # 緊急速報メールはどのトラッカーの情報も配信可能な為
        # 配信先ID で判定
        # テンプレート生成
        # XML Body 生成
        # Body root element 生成
        if DST_LIST['ugent_mail_ids'].include?(delivery_place_id)
          element     = 'pcx_um:UrgentMail'
          commons_xml = DST_LIST['commons_xml'][0]
          # 緊急速報メールのBody 部はxml_body に保持しない為生成
          xml_body    = create_commons_area_mail_body
          title  = DST_LIST['tracker_title'][UGENT_MAIL_ID]
        else
          element     = DST_LIST['destination_xpath'][self.tracker_id]
          commons_xml = DST_LIST['commons_xml'][self.tracker_id]
          xml_body    = self.xml_body
          # tracker_id に紐付く標題を設定
          title  = DST_LIST['tracker_title'][self.tracker_id]
        end

        file = File.new("#{Rails.root}/plugins/lgdis/files/xml/#{commons_xml}")
        # Xmlドキュメントの生成
        doc  = REXML::Document.new(file)

        # メッセージID を設定
        # 送付毎に変わるID で管理する必要なし
        distribution_id = UUIDTools::UUID.random_create.to_s

        # XML Body 部編集処理
        # XML 生成時に名前空間を明示的に指定しないとエラーとなる為準備
        start_element = DST_LIST['commons_xml_field']['namespace_start_tag']
        end_element   = DST_LIST['commons_xml_field']['namespace_end_tag']
        if xml_body.present?
          xml_body = start_element + xml_body + end_element
          xml_body = REXML::Document.new(xml_body).elements["//#{element}"]
        end

        # status(更新種別), uuid, edition_num(版番号)を設定
        edition_mng = find_edition_mng(delivery_place_id)
        edition_fields_map = set_edition_mng_field(edition_mng)
        edition_num = edition_fields_map['edition_num']

        # 運用種別フラグ
        operation_flg = DST_LIST['commons_xml_field']['edxl_status'][self.project_id]
        operation_flg = operation_flg.blank? ? 'Actual' : operation_flg

        # 更新種別設定処理
        type_update = TYPE_UPDATE[self.type_update]

        # 情報の配信対象地域を設定
        area_ary = []
        self.delivered_area.split(',').each do |code|
          area_ary.push get_area_name(code)
        end

        # edxl 部要素追加
        doc.elements["//edxlde:distributionID"].add_text(distribution_id)
        doc.elements["//edxlde:dateTimeSent"].add_text(Time.now.xmlschema)
        doc.elements["//edxlde:EDXLDistribution/edxlde:distributionStatus"].add_text(operation_flg)
        doc.elements["//edxlde:EDXLDistribution/edxlde:distributionType"].add_text(type_update)
        doc.elements["//edxlde:combinedConfidentiality"].add_text(DST_LIST['commons_xml_field']['confidential_message'])

        # 情報の配信対象地域は複数選択可能な為、targetAre 単位で追加
        area_ary.each do |area|
          area_code, area_name = area.split(":")
          doc.elements["//edxlde:combinedConfidentiality"].next_sibling = REXML::Element.new("commons:targetArea")
          doc.elements["//commons:targetArea"].add_element("commons:areaName").add_text(area_name)
          doc.elements["//commons:targetArea"].add_element("commons:jisX0402").add_text(area_code)
        end

        doc.elements["//edxlde:contentDescription"].add_text(self.summary)
        if DST_LIST['ugent_mail_ids'].include? delivery_place_id # 緊急速報メールの場合のみ
          doc.elements["//edxlde:contentDescription"].next_sibling = REXML::Element.new("edxlde:consumerRole")
          doc.elements["//edxlde:consumerRole"].add_element("edxlde:valueListUrn").add_text('publicCommons:media:urgentmail:carrier')
          doc.elements["//edxlde:consumerRole"].add_element("edxlde:value").add_text(DST_LIST['commons_xml_field']['carrier'][delivery_place_id])
        end

        # Control 部要素追加
        doc.elements["//Control/edxlde:distributionStatus"].add_text(operation_flg)
        doc.elements["//EditorialOffice/pcx_eb:OrganizationCode"].add_text(DST_LIST['commons_xml_field']['organization_code']) # 固定値
        doc.elements["//EditorialOffice/pcx_eb:OfficeName"].add_text(DST_LIST['commons_xml_field']['editorial_office'])
        doc.elements["//EditorialOffice/pcx_eb:OrganizationName"].add_text(DST_LIST['commons_xml_field']['organization_name']) # 固定値
        doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:OrganizationCode"].add_text(DST_LIST['commons_xml_field']['organization_code']) # 固定値
        doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:OfficeName"].add_text(DST_LIST['commons_xml_field']['publishing_office'])
        unless DST_LIST['commons_xml_field']['contact_type'].blank? # 発表部署情報(電話番号)が存在する場合のみ
          ele = REXML::Element.new("pcx_eb:ContactInfo")
          ele.add_attribute("pcx_eb:contactType","phone")
          doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:OfficeName"].next_sibling = ele
          doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:ContactInfo"].add_text(DST_LIST['commons_xml_field']['contact_type'].to_s)
        end
        doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:OfficeLocation/commons:areaName"].add_text(DST_LIST['commons_xml_field']['area_address']) # 固定値
        doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:OfficeDomainName"].add_text(DST_LIST['commons_xml_field']['office_domain']) # 固定値
        doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:OrganizationName"].add_text(DST_LIST['commons_xml_field']['organization_name']) # 固定値
        if edition_fields_map['status'] == 3 # 更新種別が取消の場合のみ
          doc.elements["//PublishingOffice"].next_sibling = REXML::Element.new("Errata")
          doc.elements["//Errata"].add_element("pcx_eb:Description").add_text(self.description_cancel)
          doc.elements["//Errata"].add_element("pcx_eb:Datetime").add_text(self.updated_on.xmlschema)
        end

        # Head 部要素追加
        doc.elements["//pcx_ib:Title"].add_text(I18n.t('target_municipality') + ' ' + self.project.name + ' ' +  (title.present? ? title : '緊急速報メール'))
        doc.elements["//pcx_ib:CreateDateTime"].add_text(self.created_on.xmlschema)
        doc.elements["//pcx_ib:FirstCreateDateTime"].add_text(self.created_on.xmlschema)
        doc.elements["//pcx_ib:ReportDateTime"].add_text(self.published_at.xmlschema) unless self.published_at.blank?
        unless self.closed_at.blank? # 公開終了日時が設定されている場合のみ
          doc.elements["//pcx_ib:ReportDateTime"].next_sibling = REXML::Element.new("pcx_ib:ValidDateTime")
          doc.elements["//pcx_ib:ValidDateTime"].add_text(self.closed_at.xmlschema)
        end
        unless self.opened_at.blank? # 公開開始日時が設定されている場合のみ
          doc.elements["//pcx_ib:ReportDateTime"].next_sibling = REXML::Element.new("pcx_ib:TargetDateTime")
          doc.elements["//pcx_ib:TargetDateTime"].add_text(self.opened_at.xmlschema)
        end
        doc.elements["//pcx_ib:Head/edxlde:distributionID"].add_text(distribution_id)
        doc.elements["//pcx_ib:Head/edxlde:distributionType"].add_text(type_update)
        doc.elements["//pcx_ib:Head/commons:documentRevision"].add_text("#{edition_num}")
        doc.elements["//pcx_ib:Head/commons:previousDocumentRevision"].add_text("#{edition_num - 1}")
        doc.elements["//pcx_ib:Head/commons:documentID"].add_text(edition_fields_map['uuid'])
        doc.elements["//pcx_ib:Text"].add_text(self.summary)
        doc.elements["//pcx_ib:Areas/pcx_ib:Area/commons:areaName"].add_text(DST_LIST['commons_xml_field']['area_name'])

        # Body 部
        doc.elements["//pcx_ib:Head"].next_sibling = xml_body if xml_body.present?
        # 補足情報追加処理
        # 避難勧告・指示、避難所情報、被害情報 時のみ追加
        if self.name_in_custom_field_value(COMPLEMENTARYINFO_ID).present? && !DST_LIST['ugent_mail_ids'].include?(delivery_place_id) && DST_LIST['comp_info_trackers'].include?(self.tracker_id)
          doc.elements["//#{DST_LIST['comp_info_xpath'][self.tracker_id]}"].add_text(self.name_in_custom_field_value(DST_LIST['custom_field_delivery']['comp_info']))
        else
          doc.delete_element("//#{DST_LIST['comp_info_xpath'][self.tracker_id]}")
        end

        # Edxl 部要素追加
        doc.elements["//commons:contentObject/commons:publishingOfficeName"].add_text(DST_LIST['commons_xml_field']['publishing_office'])
        doc.elements["//commons:contentObject/commons:publishingOfficeID"].add_text(DST_LIST['commons_xml_field']['organization_code']) # 固定値
        doc.elements["//commons:contentObject/commons:previousDocumentRevision"].add_text("#{edition_num - 1}")
        doc.elements["//commons:contentObject/commons:documentRevision"].add_text("#{edition_num}")
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

      # 公共コモンズ用XML 作成処理(イベント・お知らせBody部)
      # ==== Args
      # ==== Return
      # _doc_ :: REXML::Document
      # ==== Raise
      def create_commons_event_body
        title  = DST_LIST['tracker_title'][self.tracker_id]
        doc =  REXML::Document.new
        doc.add_element("pcx_gi:GeneralInformation") # root

        info_code = self.code_in_custom_field_value(DST_LIST['custom_field_delivery']['info_classification'])
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:DisasterInformationType").add_text(info_code)
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_eb:Disaster").add_element("pcx_eb:DisasterName").add_text("#{self.project.name}")
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:Category").add_text("#{DST_LIST["tracker_grouping"][self.tracker_id][0]}")
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:SubCategory").add_text("#{DST_LIST["tracker_grouping"][self.tracker_id][1]}")
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:Title").add_text(I18n.t('target_municipality') + ' ' + self.project.name + ' ' + title)
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:Description").add_text("#{self.description}")
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:URL").add_text("#{self.name_in_custom_field_value(URL_ID)}") if self.name_in_custom_field_value(URL_ID).blank?

        return doc.to_s
      end

      private

      # 公共コモンズ用XML 作成処理(エリアメールBody部)
      # ==== Args
      # ==== Return
      # _doc_ :: REXML::Document 文字列
      # ==== Raise
      def create_commons_area_mail_body
        doc =  REXML::Document.new
        doc.add_element("pcx_um:UrgentMail") # root
        doc.elements["//pcx_um:UrgentMail"].add_element("pcx_um:Information")

        doc.elements["//pcx_um:Information"].add_element("pcx_um:Title").add_text("#{self.mail_subject}")
        doc.elements["//pcx_um:Information"].add_element("pcx_um:Message").add_text("#{self.summary}")

        return doc.to_s
      end

      # 版番号管理テーブル用フィールド設定処理
      # UUID, 更新種別(status), 版番号(edition_num) を
      # ハッシュで返却します
      # ==== Args
      # _edition_mng_ :: 版番号管理オブジェクト
      # ==== Return
      # _edition_field_map_ :: uuid, status, edition_num のハッシュ
      # ==== Raise
      def set_edition_mng_field(edition_mng)
        uuid        = edition_mng.blank? || self.type_update == '1' ? \
                      UUIDTools::UUID.random_create.to_s : edition_mng.uuid

        status      = self.type_update.to_i

        edition_num = edition_mng.blank? || self.type_update == '1' ? \
                      1 : edition_mng.edition_num + 1

        edition_field_map = Hash.new
        edition_field_map.store('uuid', uuid)
        edition_field_map.store('status', status)
        edition_field_map.store('edition_num', edition_num)

        return edition_field_map
      end

      # 版番号管理テーブル検索処理
      #
      # 緊急速報メール、お知らせ・イベントは1チケットで
      # 一つの版番号、UUID を管理する
      # 上記以外のコモンズの配信内容に関しては、
      # プロジェクトに紐付くトラッカー毎に一つの版番号、UUID を管理する
      # ==== Args
      # _delivery_place_id_ :: 配信先ID
      # ==== Return
      # _edition_mng_ :: 版番号管理オブジェクト
      # ==== Raise
      def find_edition_mng(delivery_place_id)
        # イベント・お知らせ のトラッカー かつ 緊急速報メール以外
        # イベント・お知らせ のトラッカー かつ 緊急速報メールのdelivery_place_id
        # イベント・お知らせ 以外のトラッカー かつ 緊急速報メール以外
        # イベント・お知らせ 以外のトラッカー かつ 緊急速報メールのdelivery_place_id
        condition_str = ''
        condition_ary = []
        if DST_LIST['general_info_ids'].include?(self.tracker_id)
          condition_str = 'issue_id = ?'
          condition_ary.push self.id
        else
          condition_str = 'project_id = ? and tracker_id = ?'
          condition_ary.push self.project_id, self.tracker_id
        end

        if DST_LIST['ugent_mail_ids'].include?(delivery_place_id)
          condition_str << ' and delivery_place_id = ?'
          condition_ary.push delivery_place_id
        else
          condition_str << ' and delivery_place_id not in (?)'
          condition_ary.push DST_LIST['ugent_mail_ids']
        end
        condition_ary.unshift(condition_str)
        edition_mng = EditionManagement.find(:first,
                                             :order => 'updated_at desc',
                                             :conditions => condition_ary)
        return edition_mng
      end

      # カスタムフィールドのエリア名取得処理
      # ==== Args
      # _code_ :: エリアコード
      # ==== Return
      # _area :: エリアコード:エリア名の文字列
      # ==== Raise
      def get_area_name(code)
        areas = IssueCustomField.find_by_id(DST_LIST["custom_field_list"]["area"]["id"]).possible_values
        areas.each do |area|
          key, value = area.split(":")
          return area if key == code
        end
      end
    end
  end
end

Issue.send(:include, Lgdis::IssuePatch)

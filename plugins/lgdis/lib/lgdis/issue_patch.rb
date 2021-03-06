# encoding: utf-8
require_dependency 'issue'
require 'resque_scheduler'
require 'resque_scheduler/server'

module Lgdis
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        has_many :issue_geographies,  :dependent => :destroy
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
        validates :mail_subject, :length => {:maximum => 255}

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
          'disaster_info_type',
          :if => lambda {|issue, user| issue.new_record? || user.allowed_to?(:edit_issues, issue.project) }

        alias_method_chain :copy_from, :geographies
      end
    end

    module ClassMethods
      # 属性のローカライズ名取得
      # validateエラー時のメッセージに使用されます。
      # "field_" + 属性名 でローカライズします。
      # ※"summary"の場合、既存の翻訳ファイルと重複するため、"plugin_"を接頭辞として追加する。
      # ==== Args
      # _attr_ :: 属性名
      # _args_ :: args
      # ==== Return
      # 項目名
      # ==== Raise
      def self.human_attribute_name(attr, *args)
        attr = "plugin_#{attr}" if attr == "summary"
        super(attr, args)
      end
    end

    module InstanceMethods
      class InvalidStatusTo < StandardError; end
      # 更新種別
      TYPE_UPDATE = DST_LIST['type_update']

      # 緊急速報メール の定義用トラッカーid(実在しないトラッカー)
      # destination_list.yml commons_xml、tracker_title に紐付くID
      UGENT_MAIL_ID = 0
      # チケットの説明使用ID
      DESCRIPTION_ID = [2, 3, 4, 5, 6, 8, 9] 
      # 公共情報コモンズ状態遷移型情報定義トラッカーID
      COMMONS_TRANSITION_IDS = [1, 2, 16, 18]
      # 公共情報コモンズの外部配信先ID配列
      COMMONS_PLACE_IDS = DST_LIST['delivery_place_group_commons'].map{|o| o["id"]}
      # 緊急速報メールの外部配信先ID配列
      UGENT_MAIL_PLACE_IDS = DST_LIST['delivery_place_group_urgent_mail'].map{|o| o["id"]}
      # ** 号配備メールの外部配信先ID配列
      DEPLOYED_MAIL_PLACE_IDS = DST_LIST['delivery_place_group_deployed_mail'].map{|o| o["id"]}
      # RSS情報の外部配信先ID配列
      RSS_PLACE_IDS = DST_LIST['delivery_place_rss'].map{|o| o["id"]}
      # 版番号管理ステータス
      NEW_STATUS    = 1
      UPDATE_STATUS = 2
      CANCEL_STATUS = 3
      # 訓練用メッセージ
      TRAINING_MESSAGE = "【災害訓練】"

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

      # 配信要求処理
      # ==== Args
      # _ext_out_ary_ :: 外部配信要求対象配列
      # ==== Return
      # 処理結果:true(成功)/false(失敗)
      # エラー内容は本インスタンス(Issueオブジェクト)のerrorsを参照のこと
      # ==== Raise
      def request_delivery(ext_out_target)
        success = false
        transaction do
          # イベント・お知らせ のxml_body 部を生成
          if DST_LIST['general_info_ids'].include?(self.tracker_id) &&
              ext_out_target.include?(DST_LIST['delivery_place'][1]['id'].to_s)
            self.xml_body = create_commons_event_body
          end
          if DST_LIST['events_ids'].include?(self.tracker_id) &&
              ext_out_target.include?(DST_LIST['delivery_place'][1]['id'].to_s)
            self.xml_body = create_commons_event_info_body
          end
          raise ActiveRecord::Rollback unless self.save

          error_messages = []
          DeliveryHistory.create_for_history(self, ext_out_target).each do |dh|
            dh.errors.full_messages.each do |m|
              self.errors.add(:base, "#{l('label_delivery_place')}が\"#{DST_LIST['delivery_place'][dh.delivery_place_id]['name']}\"の場合は、#{m}")
            end
          end
          raise ActiveRecord::Rollback if self.errors.present?

          # チケットへの配信要求履歴書き込み
          register_issue_journal_request(ext_out_target)

          success = true
        end
        return success
      end

      # 配信要求履歴書き込み処理
      # ==== Args
      # _ext_out_ary_ :: 外部配信要求対象配列
      # ==== Return
      # ==== Raise
      def register_issue_journal_request(ext_out_ary)
        notes = []
        message = ""
        d_id = 0
        request_date = self.updated_on.strftime("%Y/%m/%d %H:%M:%S")
        notes << "#{request_date}に、以下の配信要求を行いました。"
        ext_out_ary.each do |delivery_place_id|
          notes << (DST_LIST["delivery_place"][delivery_place_id.to_i]||{})["name"].to_s
          d_id = delivery_place_id.to_i
          if DESCRIPTION_ID.include?(d_id)
            message = self.add_url_and_training(self.description, d_id, self.project_id)
          else
            message = self.add_url_and_training(self.summary, d_id, self.project_id)
          end
          notes << message
        end
        self.init_journal(User.current, notes.join("\n"))
        self.save!
      end

      # 配信処理
      # ==== Args
      # _delivery_history_ :: DeliveryHistoryオブジェクト
      # _status_to_ :: 更新先ステータス
      # ==== Return
      # DeliveryHistoryオブジェクト
      # ==== Raise
      def deliver(delivery_history, status_to)
        case status_to
          when 'reject'
            raise(InvalidStatusTo, delivery_history.status) unless ['request','reserve'].include?(delivery_history.status)
        end

        begin
          delivery_place_id = delivery_history.delivery_place_id
          summary = create_summary(delivery_history)
          delivery_job_class = eval(DST_LIST['delivery_place'][delivery_place_id]['delivery_job_class'])
          test_flag = DST_LIST['test_prj'][self.project_id]
          case status_to
          when 'reserve'
            # resque(resque-scheduler)で配信を行う
            if delivery_history.schedulable?
              enqueue_datetime = delivery_history.opened_at
              if delivery_history.for_commons? || delivery_history.for_urgent_mail?
                enqueue_datetime = Time.now
              end
              # ATOMはresque対象外
              unless delivery_history.for_atom?
                Resque.enqueue_at(enqueue_datetime, delivery_job_class, delivery_history.id, summary, test_flag)
              end
              delivery_history.update_attributes({:status => status_to, :respond_user_id => User.current.id, :process_date => Time.now})
            else
              status_to = delivery_history.status
            end
            self.save!
          when 'reject'
            # 配信予定のキューを取り消す
            if delivery_history.rejectable?
              # 職員招集メールはargsがハッシュ値のため、公開開始日時をkeyに削除する。
              if DEPLOYED_MAIL_PLACE_IDS.include?(delivery_place_id)
                Resque.next_item_for_timestamp(delivery_history.opened_at)
              else
                Resque.remove_delayed_job_from_timestamp(delivery_history.opened_at, delivery_job_class, delivery_history.id, summary, test_flag)
              end
              delivery_history.update_attributes({:status => status_to, :respond_user_id => User.current.id, :process_date => Time.now})
              register_issue_journal_reject(delivery_history) # チケットへの配信要求却下履歴書き込み
            else
              status_to = delivery_history.status
            end
          end
#        rescue

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

      # 配信要求却下履歴書き込み処理
      # ==== Args
      # _delivery_history_ :: DeliveryHistoryオブジェクト
      # ==== Return
      # ==== Raise
      def register_issue_journal_reject(delivery_history)
        notes = []
        message = ""
        delivery_name = (DST_LIST["delivery_place"][delivery_history.delivery_place_id]||{})["name"].to_s
        delivery_process_date = delivery_history.process_date.strftime("%Y/%m/%d %H:%M:%S")
        notes << "#{delivery_process_date}に、 #{delivery_name}配信要求を却下しました。"
        if DESCRIPTION_ID.include?(delivery_history.delivery_place_id)
          message = self.add_url_and_training(self.description, delivery_history.delivery_place_id, self.project_id)         
        else
          message = self.add_url_and_training(delivery_history.summary, delivery_history.delivery_place_id, self.project_id)
        end
        notes << message
        self.init_journal(delivery_history.respond_user, notes.join("\n"))
        self.save!
      end

      # RSS情報配信開始履歴書き込み処理
      # ==== Args
      # _delivery_history_ :: DeliveryHistoryオブジェクト
      # ==== Return
      # ==== Raise
      def register_issue_journal_rss_deliver(delivery_history)
        notes = []
        delivery_name = (DST_LIST["delivery_place"][delivery_history.delivery_place_id]||{})["name"].to_s
        delivery_process_date = delivery_history.process_date.strftime("%Y/%m/%d %H:%M:%S")
        notes << "#{delivery_process_date}に、 #{delivery_name}配信を開始しました。"
        notes << delivery_history.summary
        self.init_journal(delivery_history.respond_user, notes.join("\n"))
        self.save!
      end

      # 配信内容作成処理
      # ==== Args
      # _delivery_history_ :: DeliveryHistoryオブジェクト
      # ==== Return
      # 配信内容
      # ==== Raise
      def create_summary(delivery_history)
        delivery_place_id = delivery_history.delivery_place_id
        return eval("self.#{DST_LIST['delivery_place'][delivery_place_id]['create_msg_method']}(delivery_history)")
      end

      # Twitter 用配信メッセージ作成処理
      # ==== Args
      # _delivery_history_ :: DeliveryHistoryオブジェクト
      # ==== Return
      # 配信内容文字列
      # ==== Raise
      def create_twitter_msg(delivery_history)
        summary = self.add_url_and_training(delivery_history.summary, delivery_history.delivery_place_id, self.project_id)
        return summary
      end

      # Facebook 用配信メッセージ作成処理
      # ==== Args
      # _delivery_history_ :: DeliveryHistoryオブジェクト
      # ==== Return
      # 配信内容文字列
      # ==== Raise
      def create_facebook_msg(delivery_history)
        summary = self.add_url_and_training(self.description, delivery_history.delivery_place_id, self.project_id)
        return summary
      end

      # メール用 配信メッセージ作成処理
      # ==== Args
      # _delivery_history_ :: DeliveryHistoryオブジェクト
      # ==== Return
      # 配信内容ハッシュ
      # ==== Raise
      def create_smtp_msg(delivery_history)
        summary = Hash.new
        # TODO:件名、本文が未決
        delivery_place_id = delivery_history.delivery_place_id
        str = self.add_url_and_training(self.description, delivery_place_id, self.project_id)

        raise "送信先アドレス設定がありません" unless to = DST_LIST['delivery_place'][delivery_place_id]['to']
        summary.store('mailing_list_name', to)
        summary.store('title', delivery_history.mail_subject)
        summary.store('message', str)
        return summary
      end

      # ATOM 用 配信メッセージ作成処理
      # ==== Args
      # _delivery_history_ :: DeliveryHistoryオブジェクト
      # ==== Return
      # 配信内容
      # ==== Raise
      def create_atom_msg(delivery_history)
        issue = self # evelの中でissueが使われている為
        content = ""
        DST_LIST["link_disaster_portal_tracker_group"][self.tracker_id].each do | label_value |
          # content 内容作成
          #日付などの変換処理で 空の値をstrftime 処理をするとエラーでおちるのを防ぐため
         begin
           label_value_tmp = eval(label_value["value"])
         rescue
           label_value_tmp = ""
         end

          content += label_value["label"] + ':' + label_value_tmp + "\n"
        end
        return {'message' => content}
      end

      # 災害訓練,URL 追加処理
      # ==== Args
      # _contents_ :: コンテンツ文字列
      # _delivery_place_id_ :: 外部配信先ID
      # _mail_subject_ :: 情報のタイトル
      # _published_at_ :: 情報の発表日時
      # _project_id_ :: プロジェクトID
      # ==== Return
      # 引数のコンテンツ文字列に災害訓練、URLを追加した文字列
      # ==== Raise
      def add_url_and_training(contents, delivery_place_id, project_id)
        # 災害訓練モード判定
        add_message = ""
        add_message = TRAINING_MESSAGE + "\n" if DST_LIST['training_prj'][project_id]
        add_message = add_message + contents.to_s
        if DEPLOYED_MAIL_PLACE_IDS.include?(delivery_place_id)
          url = DST_LIST['lgdsf_url']
          add_message = add_message + "\n" + url.to_s if (url.to_s).size > 0
        end 
        return add_message
      end

      # 公共コモンズ用XML 作成処理
      # Control部, Head部, Body部を結合し
      # 配信内容を作成
      # ==== Args
      # _delivery_history_ :: DeliveryHistoryオブジェクト
      # ==== Return
      # _doc_ :: 配信内容
      # ==== Raise
      def create_commons_msg(delivery_history)
        # 緊急速報メールはどのトラッカーの情報も配信可能な為
        # 配信先ID で判定
        # テンプレート生成
        # XML Body 生成
        # Body root element 生成
        delivery_place_id = delivery_history.delivery_place_id
        if UGENT_MAIL_PLACE_IDS.include?(delivery_place_id)
          element     = 'pcx_um:UrgentMail'
          commons_xml = DST_LIST['commons_xml'][UGENT_MAIL_ID]
          # 緊急速報メールのBody 部はxml_body に保持しない為生成
          xml_body    = create_commons_area_mail_body(delivery_history)
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
        edition_fields_map = set_edition_mng_field(edition_mng, delivery_place_id)
        edition_num = edition_fields_map['edition_num']

        # 運用種別フラグ
        prj_mode = ""
        if DST_LIST['training_prj'][self.project_id]
          prj_mode = "training"
        elsif DST_LIST['test_prj'][self.project_id]
          prj_mode = "test"
        else
          prj_mode = "normal"
        end
        operation_flg = DST_LIST['commons_xml_field']['edxl_status'][prj_mode]

        # 更新種別設定処理
        type_update = TYPE_UPDATE[edition_fields_map['status']]

        # 情報の配信対象地域を設定
        area_ary = []
        self.delivered_area.split(',').each do |code|
          area_ary.push get_area_name(code)
        end

        # edxl 部要素追加
        doc.elements["//edxlde:distributionID"].add_text(distribution_id)
        doc.elements["//edxlde:senderID"].add_text(DST_LIST['commons_xml_field']['sender_id'])
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

        commons_summary = add_url_and_training(delivery_history.summary, delivery_place_id, self.project_id)
        doc.elements["//edxlde:contentDescription"].add_text(commons_summary)
        if UGENT_MAIL_PLACE_IDS.include? delivery_place_id # 緊急速報メールの場合のみ
          doc.elements["//edxlde:contentDescription"].next_sibling = REXML::Element.new("edxlde:consumerRole")
          doc.elements["//edxlde:consumerRole"].add_element("edxlde:valueListUrn").add_text('publicCommons:media:urgentmail:carrier')
          doc.elements["//edxlde:consumerRole"].add_element("edxlde:value").add_text(DST_LIST['delivery_place'][delivery_place_id]['commons_xml_carrier'])
        end

        # Control 部要素追加
        doc.elements["//Control/edxlde:distributionStatus"].add_text(operation_flg)
        doc.elements["//EditorialOffice/pcx_eb:OrganizationCode"].add_text(DST_LIST['commons_xml_field']['organization_code']) # 固定値
        doc.elements["//EditorialOffice/pcx_eb:OfficeName"].add_text(DST_LIST['commons_xml_field']['editorial_office'])
        doc.elements["//EditorialOffice/pcx_eb:OrganizationName"].add_text(DST_LIST['commons_xml_field']['organization_name']) # 固定値
        doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:OrganizationCode"].add_text(DST_LIST['commons_xml_field']['organization_code']) # 固定値
        doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:OfficeName"].add_text(DST_LIST['commons_xml_field']['publishing_office'])
        doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:OfficeNameKana"].add_text(DST_LIST['commons_xml_field']['publishing_office_kana'])
        unless DST_LIST['commons_xml_field']['contact_type'].blank? # 発表部署情報(電話番号)が存在する場合のみ
          doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:ContactInfo"].add_text(DST_LIST['commons_xml_field']['contact_type'].to_s)
        else
          doc.delete_element("//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:ContactInfo")
        end
        doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:OfficeLocation/commons:areaName"].add_text(DST_LIST['commons_xml_field']['area_address']) # 固定値
        doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:OfficeDomainName"].add_text(DST_LIST['commons_xml_field']['office_domain']) # 固定値
        doc.elements["//PublishingOffice/pcx_eb:OfficeInfo/pcx_eb:OrganizationName"].add_text(DST_LIST['commons_xml_field']['organization_name']) # 固定値
        if edition_fields_map['status'] == CANCEL_STATUS ||
           (edition_fields_map['status'] == UPDATE_STATUS && delivery_history.description_cancel.present?)
          doc.elements["//PublishingOffice"].next_sibling = REXML::Element.new("Errata")
          doc.elements["//Errata"].add_element("pcx_eb:Description").add_text(delivery_history.description_cancel)
          doc.elements["//Errata"].add_element("pcx_eb:DateTime").add_text(delivery_history.updated_at.xmlschema)
        end

        # Head 部要素追加
        doc.elements["//pcx_ib:Title"].add_text(I18n.t('target_municipality') + ' ' + self.project.name + ' ' +  (title.present? ? title : '緊急速報メール'))
        doc.elements["//pcx_ib:CreateDateTime"].add_text(Time.now.xmlschema)
        doc.elements["//pcx_ib:FirstCreateDateTime"].add_text((edition_mng.blank? ? Time.now.xmlschema : edition_mng.created_at.xmlschema))
        doc.elements["//pcx_ib:ReportDateTime"].add_text(delivery_history.published_at.xmlschema) unless delivery_history.published_at.blank?
        unless delivery_history.closed_at.blank? # 公開終了日時が設定されている場合のみ
          doc.elements["//pcx_ib:ReportDateTime"].next_sibling = REXML::Element.new("pcx_ib:ValidDateTime")
          doc.elements["//pcx_ib:ValidDateTime"].add_text(delivery_history.closed_at.xmlschema)
        end
        unless delivery_history.opened_at.blank? # 公開開始日時が設定されている場合のみ
          doc.elements["//pcx_ib:ReportDateTime"].next_sibling = REXML::Element.new("pcx_ib:TargetDateTime")
          doc.elements["//pcx_ib:TargetDateTime"].add_text(delivery_history.opened_at.xmlschema)
        end
        doc.elements["//pcx_ib:Head/edxlde:distributionID"].add_text(distribution_id)
        doc.elements["//pcx_ib:Head/edxlde:distributionType"].add_text(type_update)
        doc.elements["//pcx_ib:Head/commons:documentRevision"].add_text("#{edition_num}")
        doc.elements["//pcx_ib:Head/commons:previousDocumentRevision"].add_text("#{edition_num - 1}")
        doc.elements["//pcx_ib:Head/commons:documentID"].add_text(edition_fields_map['uuid'])
        doc.elements["//pcx_ib:Text"].add_text(commons_summary)
        doc.elements["//pcx_ib:Areas/pcx_ib:Area/commons:areaName"].add_text(DST_LIST['commons_xml_field']['area_name'])

        # Body 部
        doc.elements["//pcx_ib:Head"].next_sibling = xml_body if xml_body.present?
        # 補足情報追加処理
        # 避難勧告・指示、避難所情報、被害情報 時のみ追加
        if self.name_in_custom_field_value(DST_LIST['custom_field_delivery']['comp_info']).present? && !UGENT_MAIL_PLACE_IDS.include?(delivery_place_id) && DST_LIST['comp_info_trackers'].include?(self.tracker_id)
          doc.elements["//#{DST_LIST['comp_info_xpath'][self.tracker_id]}"].add_text(self.name_in_custom_field_value(DST_LIST['custom_field_delivery']['comp_info']))
        else
          doc.delete_element("//#{DST_LIST['comp_info_xpath'][self.tracker_id]}")
        end

        # Edxl 部要素追加
        doc.elements["//commons:contentObject/commons:publishingOfficeName"].add_text(DST_LIST['commons_xml_field']['publishing_office'])
        doc.elements["//commons:contentObject/commons:publishingOfficeID"].add_text(DST_LIST['commons_xml_field']['organization_code']) # 固定値
        doc.elements["//commons:contentObject/commons:publishingOfficeDomainName"].add_text(DST_LIST['commons_xml_field']['office_domain']) # 固定値
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
        commons_description = self.add_url_and_training(self.description, 1, self.project_id)
        doc =  REXML::Document.new
        doc.add_element("pcx_gi:GeneralInformation") # root

        info_code = self.disaster_info_type
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:DisasterInformationType").add_text(info_code)
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_eb:Disaster").add_element("pcx_eb:DisasterName").add_text("#{self.project.name}") if info_code != "Ordinary"
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:Category").add_text("#{DST_LIST["tracker_grouping"][self.tracker_id][0]}")
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:SubCategory").add_text("#{DST_LIST["tracker_grouping"][self.tracker_id][1]}")
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:Title").add_text(I18n.t('target_municipality') + ' ' + self.project.name + ' ' + title)
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:Description").add_text(commons_description)
        doc.elements["//pcx_gi:GeneralInformation"].add_element("pcx_gi:URL").add_text(
            "#{self.name_in_custom_field_value(DST_LIST['custom_field_delivery']['related_url'])}"
            ) if self.name_in_custom_field_value(DST_LIST['custom_field_delivery']['related_url']).present?

        return doc.to_s
      end

      # 公共コモンズ用XML 作成処理(イベントBody部)
      # ==== Args
      # ==== Return
      # _doc_ :: REXML::Document
      # ==== Raise
      def create_commons_event_info_body
        doc =  REXML::Document.new
        doc.add_element("pcx_en:Event") # root

        doc.elements["//pcx_en:Event"].add_element("pcx_en:Name").add_text("#{self.subject}")
        doc.elements["//pcx_en:Event"].add_element("pcx_en:Description").add_text("#{self.description}")
        doc.elements["//pcx_en:Event"].add_element("pcx_en:URL").add_text(
            "#{self.name_in_custom_field_value(DST_LIST['custom_field_delivery']['related_url'])}"
            ) if self.name_in_custom_field_value(DST_LIST['custom_field_delivery']['related_url']).present?

        return doc.to_s
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

      private

      # 公共コモンズ用XML 作成処理(エリアメールBody部)
      # ==== Args
      # _delivery_history_ :: DeliveryHistoryオブジェクト
      # ==== Return
      # _doc_ :: REXML::Document 文字列
      # ==== Raise
      def create_commons_area_mail_body(delivery_history)
        summary = self.add_url_and_training(delivery_history.summary, delivery_history.delivery_place_id, self.project_id)
        doc =  REXML::Document.new
        doc.add_element("pcx_um:UrgentMail") # root
        doc.elements["//pcx_um:UrgentMail"].add_element("pcx_um:Information")

        doc.elements["//pcx_um:Information"].add_element("pcx_um:Title").add_text(delivery_history.mail_subject)
        doc.elements["//pcx_um:Information"].add_element("pcx_um:Message").add_text(summary)

        return doc.to_s
      end

      # 版番号管理テーブル用フィールド設定処理
      # UUID, 更新種別(status), 版番号(edition_num) を
      # ハッシュで返却します
      #
      # 例:
      # project_id = 1, tracker_id = 1, issue_id = 1
      # edition_num(版番号) = 2, status = 2(update), uuid = aaa
      # 上記のレコードがある前提で、同じproject_id, tracker_id のチケットを作成した場合
      # 「緊急速報メール・お知らせ」とその他のコモンズ配信では、
      # edition_num(版番号), status, uuid の生成方法が異なる。
      # ケース 1) 「緊急速報メール・お知らせ」の場合
      # project_id = 1, tracker_id = 1, issue_id = 2
      # edition_num(版番号) = 3, status = 2(update), uuid = aaa
      # ケース 2) その他のコモンズ配信の場合
      # project_id = 1, tracker_id = 1, issue_id = 2
      # edition_num(版番号) = 1, status = 1(update), uuid = bbb
      # ==== Args
      # _edition_mng_ :: 版番号管理オブジェクト
      # ==== Return
      # _edition_field_map_ :: uuid, status, edition_num のハッシュ
      # ==== Raise
      def set_edition_mng_field(edition_mng, delivery_place_id)
        status_flag = false
        # 緊急速報メールか、お知らせ・イベントのトラッカーで更新種別が新規の場合
        # uuid, status, edition_num を新規作成する
        if UGENT_MAIL_PLACE_IDS.include?(delivery_place_id) ||
           DST_LIST['general_info_ids'].include?(self.tracker_id) ||
           DST_LIST['events_ids'].include?(self.tracker_id)
          status_flag = self.type_update == NEW_STATUS.to_s ? true : false
        end
        # 新規配信許可時、更新種別が新規、緊急速報メールか、お知らせ・イベントのトラッカーの場合、UUID を新規生成
        uuid        = edition_mng.blank? || edition_mng.status == CANCEL_STATUS || status_flag ? \
                      UUIDTools::UUID.random_create.to_s : edition_mng.uuid

        # 新規配信許可時、更新種別が新規、緊急速報メールか、お知らせ・イベントのトラッカーで
        # 画面より情報の更新種別「取消」を選択した場合、画面の入力値を設定
        # それ以外は更新ステータス
        status      = COMMONS_TRANSITION_IDS.include?(self.tracker_id) && delivery_place_id == 1 && edition_mng.present? && edition_mng.status != CANCEL_STATUS && self.type_update == NEW_STATUS.to_s ? UPDATE_STATUS : self.type_update.to_i

        # 新規配信許可時、更新種別が新規、緊急速報メールか、お知らせ・イベントのトラッカーの場合、版番号を1に設定
        edition_num = edition_mng.blank? || edition_mng.status == CANCEL_STATUS || status_flag ? \
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
        condition_str = ''
        condition_ary = []
        if COMMONS_TRANSITION_IDS.include?(self.tracker_id) && delivery_place_id == 1
          condition_str = 'project_id = ? and tracker_id = ?'
          condition_ary.push self.project_id, self.tracker_id
        else
          condition_str = 'issue_id = ?'
          condition_ary.push self.id
        end

        if UGENT_MAIL_PLACE_IDS.include?(delivery_place_id)
          condition_str << ' and delivery_place_id = ?'
          condition_ary.push delivery_place_id
        else
          condition_str << ' and delivery_place_id not in (?)'
          condition_ary.push UGENT_MAIL_PLACE_IDS
        end
        condition_ary.unshift(condition_str)
        edition_mng = EditionManagement.find(:first,
                                             :order => 'updated_at desc',
                                             :conditions => condition_ary)
        return edition_mng
      end

    end
  end
end

Issue.send(:include, Lgdis::IssuePatch)

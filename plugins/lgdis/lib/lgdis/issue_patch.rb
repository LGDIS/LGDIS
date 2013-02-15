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
        has_many :delivery_histories

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

        alias_method_chain :copy_from, :geographies
      end
    end

    module ClassMethods
    end

    module InstanceMethods
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

      # Twitter 用配信メッセージ作成処理
      # ==== Args
      # ==== Return
      # _summary_ :: 配信内容
      # ==== Raise
      def create_twitter_msg
        summary = self.custom_field_value(DST_LIST['custom_field_delivery']['summary'])
        return summary
      end

      # Facebook 用配信メッセージ作成処理
      # ==== Args
      # ==== Return
      # _summary_ :: 配信内容
      # ==== Raise
      def create_facebook_msg
        summary = self.description
        return summary
      end

      # メール用 配信メッセージ作成処理
      # ==== Args
      # ==== Return
      # _summary_ :: 配信内容
      # ==== Raise
      def create_smtp_msg
        summary = Hash.new
        str = self.add_url_and_training(self.description, DST_LIST['smtp']['target_num'])

        # TODO
        # mailing_list の選択基準未決(手動 & 自動)
        summary.store('mailing_list_name', DST_LIST['mailing_list']['local_government_officer_mail'])
        summary.store('title', self.subject)
        summary.store('message', str)
        return summary
      end

      # 災害訓練,URL 追加処理
      # ==== Args
      # _issue_ :: チケット情報
      # ==== Return
      # _summary_ :: 配信内容
      # ==== Raise
      def add_url_and_training(contents, exit_out_id)
        url = exit_out_id==DST_LIST['smtp']['target_num'] ? \
                DST_LIST['lgdsf_url'] : DST_LIST['disaster_portal_url']

        # 災害訓練モード判定
        DST_LIST['training_prj'][self.project_id] ? \
          '【災害訓練】' + "\n" + url + "\n" + contents : url + "\n" + contents
      end

      # 公共コモンズ用XML 作成処理
      # Control部, Head部, Body部を結合し
      # 配信内容を作成
      # ==== Args
      # ==== Return
      # _doc_ :: 配信内容
      # ==== Raise
      def create_commons_msg
        # テンプレートの読み込み
        commons_xml = DST_LIST['commons_xml'][self.tracker_id]
        file = File.new("#{Rails.root}/plugins/lgdis/files/xml/#{commons_xml}")
        # Xmlドキュメントの生成
        doc  = REXML::Document.new(file)

        # tracker_id に紐付く標題を設定
        title  = DST_LIST['tracker_title'][self.tracker_id]

        edition_mng = EditionManagement.find_by_project_id_and_tracker_id(self.project_id, self.tracker_id)

        # status(更新種別), uuid, edition_num(版番号)を設定
        edition_fields_map = set_edition_mng_field(edition_mng)

        # 運用種別フラグ
        operation_flg = DST_LIST['commons_xml_field']['edxl_status'][self.project_id]
        operation_flg = operation_flg.blank? ? 'Actual' : operation_flg

        # 希望公開開始日時
        target_date = custom_field_value(DST_LIST['custom_field_delivery']['target_date'])
        target_time = custom_field_value(DST_LIST['custom_field_delivery']['target_time'])
        target_datetime = target_date.blank? || target_time.blank? ? nil : target_date + ' ' + target_time

        # 希望公開終了日時
        valid_date = custom_field_value(DST_LIST['custom_field_delivery']['valid_date'])
        valid_time = custom_field_value(DST_LIST['custom_field_delivery']['valid_time'])
        valid_datetime = valid_date.blank? || valid_time.blank? ? nil : valid_date + ' ' + valid_time

        # TODO
        # 新規フィールドの作成が必要
        # カスタムフィールドとするのか、Issue テーブルに追加するのか未決
        # Issue に追加する際は、登録画面の作成も必要

        # edxl 部要素追加
        doc.elements["//edxlde:distributionID"].add_text(edition_fields_map['uuid'])
        doc.elements["//edxlde:dateTimeSent"].add_text(Time.now.xmlschema)
        doc.elements["//edxlde:distributionStatus"].add_text(operation_flg)
        # TODO
        # 新規作成フィールド
        doc.elements["//edxlde:distributionType"].add_text('')
        doc.elements["//edxlde:combinedConfidentiality"].add_text(DST_LIST['commons_xml_field']['confidential_message'])
        # TODO
        # 新規作成フィールド
        doc.elements["//commons:targetArea/commons:areaName"].add_text('')
        doc.elements["//edxlde:contentDescription"].add_text(custom_field_value(DST_LIST['custom_field_delivery']['summary']))
        doc.elements["//edxlde:consumerRole/edxlde:valueListUrn"].add_text('publicCommons:media:urgentmail:carrier') # TODO 緊急速報メールの場合
        doc.elements["//edxlde:consumerRole/edxlde:value"].add_text(DST_LIST['commons_xml_field']['carrier'][1]) # TODO 緊急速報メールの場合

        # Control 部要素追加
        doc.elements["//edxlde:distributionStatus"].add_text(operation_flg)
        doc.elements["//EditorialOffice/pcx_eb:OfficeName"].add_text(DST_LIST['commons_xml_field']['editorial_office'])
        doc.elements["//PulishingOffice/pcx_eb:OfficeName"].add_text(DST_LIST['commons_xml_field']['pulishing_office'])
        doc.elements["//pcx_eb:contactType"].add_text(DST_LIST['contact_type']) unless DST_LIST['contact_type'].blank?
        # TODO
        # タグ名が重複
        doc.elements["//pcx_eb:Description"].add_text(custom_field_value(DST_LIST['custom_field_delivery']['corrected'])) if edition_fields_map['status'] == 0
        doc.elements["//pcx_eb:Description"].add_text(self.updated_on.xmlschema) if edition_fields_map['status'] == 0

        # Head 部要素追加
        doc.elements["//pcx_ib:Title"].add_text(I18n.t('target_municipality') + ' ' + self.project.name + ' ' +  (title.present? ? title : '緊急速報メール'))
        doc.elements["//pcx_ib:CreateDateTime"].add_text(self.created_on.xmlschema)
        doc.elements["//pcx_ib:FirstCreateDateTime"].add_text(self.created_on.xmlschema)
        # TODO
        # 報告日時の設定避難所テーブルにしか存在しない為確認
        doc.elements["//pcx_ib:ReportDateTime"].add_text('')
        doc.elements["//pcx_ib:TargetDateTime"].add_text(target_datetime.to_datetime.xmlschema) unless target_datetime.blank?
        doc.elements["//pcx_ib:ValidDateTime"].add_text(valid_datetime.to_datetime.xmlschema) unless valid_datetime.blank?
        doc.elements["//edxlde:distributionID"].add_text(edition_fields_map['uuid'])
        # TODO
        # 新規作成フィールド
        doc.elements["//edxlde:distributionType"].add_text('')
        doc.elements["//pcx_ib:Head/commons:documentRevision"].add_text("#{edition_fields_map['edition_num']}")
        doc.elements["//pcx_ib:Head/commons:documentID"].add_text(edition_fields_map['uuid'])
        doc.elements["//pcx_ib:Text"].add_text(custom_field_value(DST_LIST['custom_field_delivery']['summary']))
        doc.elements["//pcx_ib:Areas/pcx_ib:Area/commons:areaName"].add_text(DST_LIST['custom_field_delivery']['area_name'])

        # Body 部
        doc.elements["//pcx_ib:Head"].next_sibling = REXML::Document.new self.xml_body

        # Edxl 部要素追加
        doc.elements["//commons:publishingOfficeName"].add_text(DST_LIST['custom_field_delivery']['pulishing_office'])
        doc.elements["//commons:previousDocumentRevision"].add_text("#{edition_fields_map['edition_num']}")
        doc.elements["//commons:contentObject/commons:documentRevision"].add_text("#{edition_fields_map['edition_num']}")
        doc.elements["//commons:contentObject/commons:documentID"].add_text(edition_fields_map['uuid'])

        return doc
      end

      private

      # 公共コモンズ用XML 作成処理(エリアメールBody部)
      # ==== Args
      # ==== Return
      # ==== Raise
      def create_commmons_area_mail_body
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

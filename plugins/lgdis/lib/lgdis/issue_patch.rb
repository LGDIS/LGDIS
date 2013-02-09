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

      # カスタムフィールドIDより
      # チケットに紐付くカスタムフィールドのvalue を返却する
      # ==== Args
      # ==== Return
      # ==== Raise
      def custom_field_value_by_id(custom_field_id)
        value = nil
        self.custom_values.each do |custom_value|
          if custom_value.custom_field_id == custom_field_id
            value = custom_value.value
          end
        end
        return value
      end

      # 公共情報コモンズ用 配信メッセージ作成処理
      # ==== Args
      # ==== Return
      # _summary_ :: 配信内容
      # ==== Raise
      def create_commons_msg
        # TODO
        # 配信内容未作成
      end

      # Twitter 用配信メッセージ作成処理
      # ==== Args
      # ==== Return
      # _summary_ :: 配信内容
      # ==== Raise
      def create_twitter_msg
        summary = self.custom_field_value_by_id(DST_LIST['content_delivery']['summary'])
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
    end
  end
end

Issue.send(:include, Lgdis::IssuePatch)

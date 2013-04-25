# encoding: utf-8
require_dependency 'application_helper'

module Lgdis
  module ApplicationHelperPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      # 日時入力補助のjavascript作成処理
      # ==== Args
      # _field_id_ :: 項目ID
      # ==== Return
      # ==== Raise
      def calendar_with_time_for(field_id)
        include_calendar_headers_tags
        include_calendar_with_time_headers_tags
        javascript_tag("$(function() { $('##{field_id}').datetimepicker(datetimepickerOptions); });")
      end

      # 日時入力補助のjavascriptヘッダー作成処理
      # ==== Args
      # ==== Return
      # ==== Raise
      def include_calendar_with_time_headers_tags
        unless @calendar_with_time_headers_tags_included
          @calendar_with_time_headers_tags_included = true
          content_for :header_tags do
            tags = javascript_tag(
                "var datetimepickerOptions= $.extend(datepickerOptions, {" +
                    "timeText: '#{l(:time, scope: :datetimepicker)}'," +
                    "hourText: '#{l(:hour, scope: :datetimepicker)}'," +
                    "minuteText: '#{l(:minute, scope: :datetimepicker)}'," +
                    "currentText: '#{l(:current, scope: :datetimepicker)}'," +
                    "closeText: '#{l(:close, scope: :datetimepicker)}'});")
            tags << javascript_include_tag("jquery-ui-timepicker-addon", :plugin => "lgdis")
            tags
          end
        end
      end

      # 日時入力項目の設定用フォーマット処理
      # ==== Args
      # _model_ :: モデルオブジェクト
      # _field_ :: 日時項目名
      # ==== Return
      # ==== Raise
      def format_time_for_input(model, field)
        value = model[field]
        return value.localtime.strftime("%Y-%m-%d %H:%M") if value.present? && value.is_a?(Time)
        before_type_cast = "#{field}_before_type_cast"
        return model.send(before_type_cast) if model.respond_to?(before_type_cast.to_sym)
        return ""
      end

      # 文字列中の変数部分を置換する
      # 例) replace_paramsに{:user_name => "maria"}を指定すると、文字列"my name is ${user_name}."から
      #    "my name is maria."を作成して返却する。
      # ==== Args
      # _message_ :: 対象文字列(String)
      # _replace_params_ :: 流し込むキーと値の組み合わせ(Hash)
      # ==== Return
      # 置換結果(String)
      # ==== Raise
      def format_message(message, replace_params = {})
        replace_params.each do |key, value|
          message.gsub!("${#{key}}", value.to_s)
        end
        return message
      end

      # ログインユーザに配信管理権限があるか判定する
      # ==== Args
      # _issue_ :: 対象のチケット(Issue)
      # ==== Return
      # true/false
      # ==== Raise
      def allow_delivery_permission?(issue)
        User.current.roles_for_project(issue.project).each do |roles|
          roles.permissions.each do |permissions|
            return true if [permissions].flatten.include?(:request_delivery)
          end
        end
        return false
      end

    end

  end
end

ApplicationHelper.send(:include, Lgdis::ApplicationHelperPatch)

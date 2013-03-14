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

    end

  end
end

ApplicationHelper.send(:include, Lgdis::ApplicationHelperPatch)

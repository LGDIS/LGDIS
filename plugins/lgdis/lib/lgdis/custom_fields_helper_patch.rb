# encoding: utf-8
require_dependency 'custom_fields_helper'

module Lgdis
  module CustomFieldsHelperPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        alias_method_chain :custom_field_tag, :time
        alias_method_chain :custom_field_tag_for_bulk_edit, :time
        alias_method_chain :format_value, :time
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      # カスタムフィールド値のフォーマット処理
      # 日付フォーマットで、時刻入力指定がある場合は、
      # 日時でフォーマットするように変更
      # ==== Args
      # _value_ :: カスタムフィールド値
      # _field_format_ :: カスタムフィールド書式
      # ==== Return
      # フォーマットした文字列
      # ==== Raise
      def format_value_with_time(value, field_format)
        format = Redmine::CustomFieldFormat.find_by_name(field_format)
        if !value.is_a?(Array) && format.try(:edit_as) == "date" && value =~ /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/
          return begin; format_datetime(value.to_datetime); rescue; value end
        end
        return format_value_without_time(value, field_format)
      end

      # カスタムフィールド項目の作成処理
      # 日付フォーマットで、時刻入力指定がある場合は、
      # 日時入力補助付きの入力部品を作成するように変更
      # ==== Args
      # _name_ :: フォーム名
      # _custom_value_ :: CustomValueオブジェクト
      # ==== Return
      # 作成した入力部品
      # ==== Raise
      def custom_field_tag_with_time(name, custom_value)
        custom_field = custom_value.custom_field
        field_name = "#{name}[custom_field_values][#{custom_field.id}]"
        field_name << "[]" if custom_field.multiple?
        field_id = "#{name}_custom_field_values_#{custom_field.id}"

        tag_options = {:id => field_id, :class => "#{custom_field.field_format}_cf"}

        field_format = Redmine::CustomFieldFormat.find_by_name(custom_field.field_format)
        case field_format.try(:edit_as)
        when "date"
          if custom_field.include_time?
            return text_field_tag(field_name, custom_value.value, tag_options.merge(:size => 16)) +
                    calendar_with_time_for(field_id)
          end
        end

        return custom_field_tag_without_time(name, custom_value)
      end

      # カスタムフィールド項目の作成処理（複数チケットの一括変更での編集画面向け）
      # 日付フォーマットで、時刻入力指定がある場合は、
      # 日時入力補助付きの入力部品を作成するように変更
      # ==== Args
      # _name_ :: フォーム名
      # _custom_field_ :: CustomFieldオブジェクト
      # _project_ :: Projectオブジェクト
      # ==== Return
      # 作成した入力部品
      # ==== Raise
      def custom_field_tag_for_bulk_edit_with_time(name, custom_field, projects=nil)
        field_name = "#{name}[custom_field_values][#{custom_field.id}]"
        field_name << "[]" if custom_field.multiple?
        field_id = "#{name}_custom_field_values_#{custom_field.id}"

        tag_options = {:id => field_id, :class => "#{custom_field.field_format}_cf"}

        field_format = Redmine::CustomFieldFormat.find_by_name(custom_field.field_format)
        case field_format.try(:edit_as)
        when "date"
          if custom_field.include_time?
            return text_field_tag(field_name, '', tag_options.merge(:size => 16)) +
                    calendar_with_time_for(field_id)
          end
        end

        return custom_field_tag_for_bulk_edit_without_time(name, custom_field)
      end

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

    end

  end
end

CustomFieldsHelper.send(:include, Lgdis::CustomFieldsHelperPatch)

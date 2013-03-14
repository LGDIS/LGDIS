# encoding: utf-8
require_dependency 'custom_field'

module Lgdis
  module CustomFieldPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        serialize :default_value  # 初期値をシリアライズ化して格納
        alias_method_chain :validate_field_value, :connect
        alias_method_chain :validate_field_value_format, :datetime
      end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
      
      # デフォルト値を取得
      # シリアライズされた値をUTF-8にエンコーディング
      # ==== Args
      # ==== Return
      # デフォルト値
      # ==== Raise
      def default_value
        values = super()
        if values.is_a?(Array)
          values.each do |value|
            value.force_encoding('UTF-8') if value.respond_to?(:force_encoding)
          end
        end
        values || ""
      end
      
      # デフォルト値を設定
      # 設定値が配列の場合、ブランク行を除いて設定
      # 設定値が文字列で、リスト（複数選択可）の場合、改行で分割した配列を設定
      # 上記以外は、引数の設定値をそのまま設定
      # ==== Args
      # _arg_ :: 設定値
      # ==== Return
      # ==== Raise
      def default_value=(arg)
        if arg.is_a?(Array)
          super(arg.compact.collect(&:strip).select {|v| !v.blank?})
        elsif field_format == "list" && multiple?
          self.default_value = arg.to_s.split(/[\n\r]+/)
        else
          super(arg)
        end
      end

      # カスタムフィールドのバリデーション
      # 連携項目は値域チェックを行わない
      # ==== Args
      # _value_ :: 入力値
      # ==== Return
      # ==== Raise
      def validate_field_value_with_connect(value)
        return [] if [CF_CONNECT].flatten.include?(self.id)
        return validate_field_value_without_connect(value)
      end

      # カスタムフィールドの型毎のバリデーション
      # 日付フォーマットで、時刻入力指定がある場合は、
      # 既存の日付チェックを行わず、日時チェックを行うように変更
      # ==== Args
      # _value_ :: 入力値
      # ==== Return
      # エラー配列
      # ==== Raise
      def validate_field_value_format_with_datetime(value)
        if value.present? && field_format == "date" && include_time?
          err = []
          err << ::I18n.t('activerecord.errors.messages.invalid') unless CustomFormatValidator.datetime(value)
          return err
        end
        return validate_field_value_format_without_datetime(value)
      end

    end
  end
end

CustomField.send(:include, Lgdis::CustomFieldPatch)

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
    end
  end
end

CustomField.send(:include, Lgdis::CustomFieldPatch)

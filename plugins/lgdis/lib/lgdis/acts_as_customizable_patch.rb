# encoding: utf-8
require_dependency 'acts_as_customizable'

module Lgdis
  module ActsAsCustomizablePatch
    def self.included(base)
      base::InstanceMethods.send(:include, InstanceMethods)

      base::InstanceMethods.module_eval do
        unloadable
        alias_method_chain :custom_field_values, :multipul_default_values
      end
    end
    
    module InstanceMethods
      # CustomFieldValueオブジェクト配列を取得
      # カスタムフィールド値が未設定の場合（例.新しいチケット）、CustomFieldValue#valueにカスタムフィールドの初期値が設定される。
      # その際に、初期値が配列の場合、CustomFieldValue#valueが[[初期値1,初期値2,…]]のように入れ子の配列になってしまう。
      # [初期値1,初期値2,…]となるように処理を変更
      # ==== Args
      # ==== Return
      # CustomFieldValueオブジェクト配列
      # ==== Raise
      def custom_field_values_with_multipul_default_values
        custom_field_values_without_multipul_default_values.collect do |cfv|
          if cfv.value.is_a?(Array) && cfv.value.count == 1 && cfv.value.first.is_a?(Array)
            cfv.value = cfv.value.first
          end
          cfv
        end
      end
      
      # 指定されたカスタムフィールド値で、『コード:名称』の場合の名称を取得
      # ==== Args
      # _c_ :: CustomFieldオブジェクト もしくは カスタムフィールドID
      # ==== Return
      # CustomFieldValue#valueの最初の:以降の文字列（もしくは最初の:以降の文字列の配列）
      # 但し、以下のいずれかに該当する場合は、未加工のvalueを返却
      # ・カスタムフィールド書式がリスト以外の場合
      # ・valueが（配列 or 文字列）以外の場合
      # ・valueに:が存在しない場合
      # ==== Raise
      def name_in_custom_field_value(c)
        value = custom_field_value(c)
        return value unless (cv = custom_value_for(c)) && cv.custom_field.field_format == 'list'
        
        result = nil
        case value.class.name
        when "Array"
          value.each do |v|
            (result ||= []) << split_custom_field_value(v)[1]
          end
        when "String"
          result = split_custom_field_value(value)[1]
        else
          result = value
        end
        return result
      end
      
      private
      
      # 最初の:で分割
      # ==== Args
      # _value_ :: 分割対象文字列
      # ==== Return
      # 返却値1 ::":"の前 ※":"が存在しない場合は、元の値を返却
      # 返却値2 ::":"の後 ※":"が存在しない場合は、元の値を返却
      # ==== Raise
      def split_custom_field_value(value)
        return value, value unless /^([^:]*):(.*)$/ =~ value
        return $1, $2
      end
      
    end
  end
end

Redmine::Acts::Customizable.send(:include, Lgdis::ActsAsCustomizablePatch)
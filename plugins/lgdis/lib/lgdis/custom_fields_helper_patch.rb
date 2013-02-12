# -*- coding: utf-8 -*-
module Lgdis
  module CustomFieldHelperPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :custom_field_tag, :address
        alias_method_chain :custom_field_tag_for_bulk_edit, :address
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      # カスタムフィールド(住所)の入力枠を表示
      def custom_field_tag_with_address(name, custom_value)
        custom_field = custom_value.custom_field
        field_name = "#{name}[custom_field_values][#{custom_field.id}]"
        field_name << "[]" if custom_field.multiple?
        field_id = "#{name}_custom_field_values_#{custom_field.id}"
        tag_options = {:id => field_id, :class => "#{custom_field.field_format}_cf"}
        field_format = Redmine::CustomFieldFormat.find_by_name(custom_field.field_format)
        case field_format.try(:edit_as)
        when "address"
          splited_value = custom_value.value.to_s.split("/", 3)
          id_prop = "issue_custom_field_values_#{custom_field.id}"
          return hidden_field_tag(field_name, custom_value, tag_options.merge(:id => id_prop)) +
            text_field_tag(id_prop+"0", splited_value[0], tag_options.merge(:id => id_prop+"0", :size => 10)) +
            text_field_tag(id_prop+"1", splited_value[1], tag_options.merge(:id => id_prop+"1", :size => 10)) +
            text_field_tag(id_prop+"2", splited_value[2], tag_options.merge(:id => id_prop+"2", :size => 20))
        end
        return custom_field_tag_without_address(name, custom_value)
      end
      # カスタムフィールド(住所)の入力枠を表示
      def custom_field_tag_for_bulk_edit_with_address(name, custom_field, projects=nil)
        field_name = "#{name}[custom_field_values][#{custom_field.id}]"
        field_name << "[]" if custom_field.multiple?
        field_id = "#{name}_custom_field_values_#{custom_field.id}"
        tag_options = {:id => field_id, :class => "#{custom_field.field_format}_cf"}
        field_format = Redmine::CustomFieldFormat.find_by_name(custom_field.field_format)
        case field_format.try(:edit_as)
        when "address"
          splited_value = custom_value.value.to_s.split("/", 3)
          id_prop = "issue_custom_field_values_#{custom_field.id}"
          return hidden_field_tag(field_name, custom_value, tag_options.merge(:id => id_prop)) +
            text_field_tag(id_prop+"0", splited_value[0], tag_options.merge(:id => id_prop+"0", :size => 8)) +
            text_field_tag(id_prop+"1", splited_value[1], tag_options.merge(:id => id_prop+"1", :size => 8)) +
            text_field_tag(id_prop+"2", splited_value[2], tag_options.merge(:id => id_prop+"2", :size => 16))
        end
        return custom_field_tag_for_bulk_edit_without_address(name, custom_field, projects)
      end
    end
  end
end


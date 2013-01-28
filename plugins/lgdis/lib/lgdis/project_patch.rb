# encoding: utf-8
require_dependency 'project'

module Lgdis
  module ProjectPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        unloadable
        validate :skip_identifer_validation, :on => :create
        before_create :set_identifer
        alias_method_chain :identifier_frozen?, :always_frozen
        alias_method_chain :initialize, :customize
      end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
      
      # 識別子のバリデーションをスキップ
      # ==== Args
      # ==== Return
      # ==== Raise
      def skip_identifer_validation
        errors.delete(:identifier)
      end
      
      # 識別子を設定
      # ==== Args
      # ==== Return
      # ==== Raise
      def set_identifer
        # 以降、変更可とする
        @identifier_defrosted = true
        # プロジェクト識別子を設定
        seq =  connection.select_value("select nextval('project_identifier_seq')")
        self.identifier = "ishinomaki04202#{format("%015d", seq)}"
      end
      
      # 識別子の凍結状態
      # 登録前であれば、基本的に凍結（true）とするように変更
      # 但し、変更可(@identifier_defrostedがtrue)の場合は、既存の判定を行う
      # ==== Args
      # ==== Return
      # ==== Raise
      def identifier_frozen_with_always_frozen?
        return true if (new_record? && !@identifier_defrosted)
        return identifier_frozen_without_always_frozen?
      end
      
      # プロジェクト初期化処理のカスタマイズ
      # 識別子に、システムで自動採番する旨の説明を設定
      # ==== Args
      # ==== Return
      # ==== Raise
      def initialize_with_customize(attributes=nil, *args)
        initialize_without_customize  # 既存処理
        @identifier_defrosted = true  # 一時的に変更可
        self.identifier = l(:description_project_identifier_on_create)
        @identifier_defrosted = false  # 再度、凍結
      end
    end
  end
end

Project.send(:include, Lgdis::ProjectPatch)
# encoding: utf-8
require_dependency 'project'

module Lgdis
  module ProjectPatch
    IDENTIFER_PREFIX = "ishinomaki"
    
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        unloadable
        validate :skip_identifer_validation, :on => :create
        before_create :set_identifer
        after_create :import_initial_data
        alias_method_chain :identifier_frozen?, :always_freeze
        alias_method_chain :initialize, :identifier_customize
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
        self.identifier = "#{IDENTIFER_PREFIX}04202#{format("%015d", seq)}"
      end
      
      # 識別子の凍結状態
      # 登録前であれば、基本的に凍結（true）とするように変更
      # 但し、変更可(@identifier_defrostedがtrue)の場合は、既存の判定を行う
      # ==== Args
      # ==== Return
      # ==== Raise
      def identifier_frozen_with_always_freeze?
        return true if (new_record? && !@identifier_defrosted)
        return identifier_frozen_without_always_freeze?
      end
      
      # プロジェクト初期化処理のカスタマイズ
      # 識別子に、システムで自動採番する旨の説明を設定
      # ==== Args
      # ==== Return
      # ==== Raise
      def initialize_with_identifier_customize(attributes=nil, *args)
        initialize_without_identifier_customize  # 既存処理
        @identifier_defrosted = true  # 一時的に変更可
        self.identifier = l(:description_project_identifier_on_create)
        @identifier_defrosted = false  # 再度、凍結
      end
      
      # 災害コードを取得
      # ==== Args
      # ==== Return
      # 災害コード
      # ==== Raise
      def disaster_code
        self.identifier.delete(IDENTIFER_PREFIX)
      end
      
      # 各種情報初期登録処理
      # ==== Args
      # ==== Return
      # ==== Raise
      def import_initial_data
        Shelter.import_initial_data(self) #避難所
      end
    end
  end
end

Project.send(:include, Lgdis::ProjectPatch)
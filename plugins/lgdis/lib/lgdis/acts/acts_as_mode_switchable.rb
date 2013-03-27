# encoding: utf-8
module Lgdis
  module Acts::ModeSwitchable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # 依存するモデルの記録種別によってレコードを切り替える動作を、モデルに付与します。
      # 
      # 依存するモデルに、RUN_MODEハッシュ定数（※keyはSymbol）、current_modeメソッドを定義してください。
      #   class DependedModel
      #     RUN_MODE = {normal: 0,training: 1,test: 2}.freeze # サンプル
      # 
      #     def current_mode
      #       # モード判定処理を記述し、RUN_MODE定数値を返却すること
      #     end
      #   end
      # 
      # 付与するモデルのテーブルに、recode_modeカラムを追加してください。
      #   add_column :switched_model_table, :record_mode, :integer, :null => false, :default => 0
      #   # 型、default値はサンプル
      #   # 依存モデルのRUN_MODEハッシュ定数のvalueと型を一致させ、default値は考慮の上決定のこと
      # 
      # 付与するモデルに、acts_as_mode_switchableメソッドを実行してください。
      # 依存モデルクラスを引数に指定してください。
      #   class SwitchedModel < ActiveRecord::Base
      #     acts_as_mode_switchable DependedModel
      #   end
      # 
      # mode_inスコープが登録されます。通常のスコープと同じように使用してください。
      # mode_inスコープには、引数として依存するモデルオブジェクト、Symbol、直接値による指定が可能です。
      #   SwitchedModel.mode_in(DependedModel.first) # 依存するモデルオブジェクトによる指定
      #   SwitchedModel.mode_in(:test) # Symbolによる指定
      #   SwitchedModel.mode_in(2) # 直接値による指定
      # 不正な引数な場合にArgumentErrorを発生します。
      # ==== Args
      # _depended_class_ :: 依存モデルクラス
      # ==== Return
      # ==== Raise
      def acts_as_mode_switchable(depended_class)
        self.scope :mode_in, ->(mode) {
          where(record_mode:
            case mode
            when depended_class
              mode.current_mode
            when Symbol
              depended_class::RUN_MODE[mode] || raise(ArgumentError, "不正な引数です")
            else
              raise(ArgumentError, "不正な引数です") unless depended_class::RUN_MODE.values.include?(mode)
              mode
            end
          )
        }
      end

    end

  end
end
ActiveRecord::Base.send(:include, Lgdis::Acts::ModeSwitchable)

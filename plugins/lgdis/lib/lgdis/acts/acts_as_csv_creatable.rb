# encoding: utf-8
module Lgdis
  module Acts::CsvCreatable
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      # csvテンポラリファイルを生成する
      # 生成したテンポラリファイルはclose(true)にて要削除とする
      # Constantテーブルに存在する項目は、変換した上で出力する
      # ブロックが受け渡されている場合、ブロック内で最後に評価された値をボディ部に設定する
      # ==== Args
      # _objects_ :: csv出力対象となるオブジェクト配列
      # _filename_ :: csvテンポラリファイル名
      # _columns_ :: csv出力対象となる列名
      # ==== Return
      # csvテンポラリファイル
      # ==== Raise
      def create_csv(objects, filename, columns)
        # テンポラリファイルの生成
        tf = Tempfile.new(filename)
        tf.class_eval{ attr_accessor :original_filename }
        tf.original_filename = "#{filename}_#{Time.now.strftime("%Y%m%d%H%M%S")}.csv"
        
        table_name = objects.first.class.table_name
        object_const = Constant.hash_for_table(table_name)
        
        CSV.open(tf.path, "w", force_quotes: true) do |row|
          # ヘッダー部の設定
          row << columns.map{|col| l(("#{table_name}.field_" + col.to_s).to_sym) }
          # ボディ部の設定
          objects.each do |object|
            values = []
            object.attributes.each_pair do |key, value|
              next unless columns.include?(key.to_sym)
              case
              # Constantテーブルに存在する項目である場合
              when object_const[key.to_s].present?
                values << object_const[key.to_s][value]
              # Date型の項目である場合
              when object[key].is_a?(Date)
                values << format_date(value)
              # Time型の項目である場合
              when object[key].is_a?(Time)
                values << format_time(value)
              # ブロックが受け渡されている場合
              when block_given?
                values << yield(key, value)
              # その他の場合
              else
                values << value
              end
            end
            row << values
          end
        end
        return tf
      end
    end
    
    module InstanceMethods
    end
    
  end
end
ActiveRecord::Base.send(:include, Lgdis::Acts::CsvCreatable)
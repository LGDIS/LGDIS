# encoding: utf-8
module Lgdis
  module Acts::DatetimeSeparable
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      # 日時フィールドを日付、時刻フィールドに分割して扱う動作を、モデルに付与します。
      # 例) create_at ⇒ create_date, create_hm
      # ==== Args
      # _columns_ :: 分割する日時フィールド、もしくは日時フィールド配列
      # ==== Return
      # ==== Raise
      def acts_as_datetime_separable(*columns)
        return if self.included_modules.include?(Lgdis::Acts::DatetimeSeparable::InstanceMethods)
    
        if columns.nil?
          raise '分割する日時フィールドの指定がありません。'
        elsif !columns.is_a?(Array)
          columns = [] << columns
        end
    
        send :include, Lgdis::Acts::DatetimeSeparable::InstanceMethods
        datetime_separable_initialize(columns)
      end
      
    end
    
    module InstanceMethods
      def self.included(base)
        base.extend ClassMethods
      end
      
      private
      
      # 日付、時刻から、attrを設定します。
      # 不正な引数の場合は、nilを設定します。
      # ==== Args
      # _attr_ :: attr
      # _date_ :: 日付（Dateもしくは文字列）
      # _hm_ :: 時刻（文字列）
      # ==== Return
      # ==== Raise
      def set_date_time_attr(attr, date, hm)
        begin
          date = Date.strptime(date.to_s, "%Y-%m-%d") unless date.is_a?(Date)
        rescue
          write_attribute(attr, nil)
          return
        end
        year, month, day = date.year, date.month, date.day
        unless /^(0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9])$/ =~ hm
          write_attribute(attr, nil)
          return
        end
        hour,min = $1, $2
        write_attribute(attr, Time.local(year, month, day, hour, min))
      end
      
      module ClassMethods
        private
        
        # 日時フィールド分割の初期処理を行います。
        # ==== Args
        # _columns_ :: 分割する日時フィールド配列
        # ==== Return
        # ==== Raise
        def datetime_separable_initialize(colmuns)
          cattr_accessor :datetime_separate_columns
          self.datetime_separate_columns = {}
          colmuns.each do |separated|
            prefix = separated.to_s.gsub("_at","")
            self.datetime_separate_columns[separated] = ["#{prefix}_date", "#{prefix}_hm"]
          end
          attr_accessor_separate_datetime
          validates_separate_datetime
        end
        
        # 日時フィールドに対して、日付、時刻フィールドに分割したアクセサを定義します。
        # ==== Args
        # ==== Return
        # ==== Raise
        def attr_accessor_separate_datetime
          self.datetime_separate_columns.each do |separated, separates|
            attr_date, attr_hm = separates
            define_method("#{attr_date}") do
              val = eval("@#{attr_date}")
              base_value = eval("self.#{separated}")
              # timezoneの考慮が必要
              # see:Redmine::I18n#format_time
              zone = User.current.time_zone
              base_value &&= zone ? base_value.in_time_zone(zone) : (base_value.utc? ? base_value.localtime : base_value)
              base_value &&= base_value.to_date
              val || base_value
            end
            
            define_method("#{attr_date}=") do |val|
              instance_variable_set("@#{attr_date}", val)
              set_date_time_attr("#{separated}", val, eval("#{attr_hm}"))
            end
            
            define_method("#{attr_hm}") do
              val = eval("@#{attr_hm}")
              base_value = eval("self.#{separated}")
              # timezoneの考慮が必要
              # see:Redmine::I18n#format_time
              zone = User.current.time_zone
              base_value &&= zone ? base_value.in_time_zone(zone) : (base_value.utc? ? base_value.localtime : base_value)
              base_value &&= base_value.strftime("%H:%M")
              val || base_value
            end
            
            define_method("#{attr_hm}=") do |val|
              instance_variable_set("@#{attr_hm}", val)
              set_date_time_attr("#{separated}", eval("#{attr_date}"), val)
            end
          end
        end
        
        # 分割した日付、時刻フィールドに対するバリデーションを定義します。
        # ==== Args
        # ==== Return
        # ==== Raise
        def validates_separate_datetime
          self.datetime_separate_columns.each do |separated, separates|
            attr_date, attr_hm = separates
            validates attr_date, :custom_format => {:type => :date}
            validates attr_date, :presence => true, :unless => "#{attr_hm}.blank?"
            validates attr_hm,   :custom_format => {:type => :time}
            validates attr_hm,   :presence => true, :unless => "#{attr_date}.blank?"
          end
        end
        
      end
      
    end
  end
end
ActiveRecord::Base.send(:include, Lgdis::Acts::DatetimeSeparable)
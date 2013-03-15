# encoding: utf-8
class CustomFormatValidator < ActiveModel::EachValidator
  # カスタム文字列バリデーション
  # optionsの:typeでタイプを指定
  # mail_address :: メールアドレス
  # phone_number :: 電話番号
  # time :: 時刻
  # date :: 日付
  # datetime :: 日時
  # ==== Args
  # _record_ :: record
  # _attribute_ :: attribute
  # _value_ :: value
  # ==== Return
  # ==== Raise
  def validate_each(record, attribute, value)
    before_type_cast = "#{attribute}_before_type_cast"
    raw_value = record.send(before_type_cast) if record.respond_to?(before_type_cast.to_sym)
    raw_value ||= value
    begin
      r = self.class.__send__(options[:type].to_s, raw_value)
    rescue
      raise "Invalid option (type) is specified."
    end

    unless r
      record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.invalid'))
    end
  end
  
  # バリデーション処理（メールアドレス）
  # ==== Args
  # _value_ :: value
  # ==== Return
  # バリデーション結果
  # ==== Raise
  def self.mail_address(value)
    value.blank? || /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/ =~ value
  end
  
  # バリデーション処理（電話番号）
  # ==== Args
  # _value_ :: value
  # ==== Return
  # バリデーション結果
  # ==== Raise
  def self.phone_number(value)
    value.blank? || /^[-0-9]+$/ =~ value
  end
  
  # バリデーション処理（日時）
  # ==== Args
  # _value_ :: value
  # ==== Return
  # バリデーション結果
  # ==== Raise
  def self.datetime(value)
    return true if value.blank?
    if value.to_s =~ /^(\d{4})(?:\/|-|.)?(\d{1,2})(?:\/|-|.)?(\d{1,2})(?:\s{1}|T)(\d{1,2}):?(\d{1,2}):?(\d{1,2})/
      begin
        DateTime.new($1.to_i,$2.to_i,$3.to_i,$4.to_i,$5.to_i,$6.to_i)
      rescue
        return false
      end
    else
      return false
    end
  end
end
# encoding: utf-8
class CustomFormatValidator < ActiveModel::EachValidator
  # カスタム文字列バリデーション
  # optionsの:typeでタイプを指定
  # mail_address :: メールアドレス
  # phone_number :: 電話番号
  # time :: 時刻
  # date :: 日付
  # ==== Args
  # _record_ :: record
  # _attribute_ :: attribute
  # _value_ :: value
  # ==== Return
  # ==== Raise
  def validate_each(record, attribute, value)
    begin
      r = __send__ options[:type].to_s, value
    rescue
      raise "Invalid option (type) is specified."
    end

    unless r
      record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.invalid'))
    end
  end
  
  private
  # バリデーション処理（メールアドレス）
  # ==== Args
  # _value_ :: value
  # ==== Return
  # バリデーション結果
  # ==== Raise
  def mail_address(value)
    value.blank? || /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/ =~ value
  end
  
  # バリデーション処理（電話番号）
  # ==== Args
  # _value_ :: value
  # ==== Return
  # バリデーション結果
  # ==== Raise
  def phone_number(value)
    value.blank? || /^[-0-9]+$/ =~ value
  end
  
  # バリデーション処理（時刻）
  # ==== Args
  # _value_ :: value
  # ==== Return
  # バリデーション結果
  # ==== Raise
  def time(value)
    value.blank? || /^(0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9])$/ =~ value
  end
  
  # バリデーション処理（日付）
  # ==== Args
  # _value_ :: value
  # ==== Return
  # バリデーション結果
  # ==== Raise
  def date(value)
    return true if value.blank?
    begin
      Date.strptime(value.to_s, "%Y-%m-%d")
    rescue
      return false
    end
  end
end
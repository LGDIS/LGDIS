# encoding: utf-8
class CustomFormatValidator < ActiveModel::EachValidator
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
  def mail_address(value)
    value.blank? || /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/ =~ value
  end
  
  def phone_number(value)
    value.blank? || /^[-0-9]+$/ =~ value
  end
  
  def time(value)
    value.blank? || /^(0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9])$/ =~ value
  end
  
  def date(value)
    return true if value.blank?
    begin
      Date.strptime(value.to_s, "%Y-%m-%d")
    rescue
      return false
    end
  end
end
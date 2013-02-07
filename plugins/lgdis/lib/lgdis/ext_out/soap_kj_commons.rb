# -*- encoding: utf-8 -*-
class Lgdis::ExtOut::SOAP_KJcommons  < ActiveRecord::Base
#   require 'savon'
#   require 'tsutsumi-module'
  def self.send_message(msg_hash, test_flg)
    modulename="SOAP_KJcommons"
    o = IfCommon.new

    begin
      if test_flg.blank?
	      #TODO: WS-Security+SOAP モジュール組み込み			
      end
      #TODO: アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      Rails.logger.info("#{o.create_log_time(msg_hash,modulename)}")
      status = true
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{o.create_log_time(msg_hash,modulename)}")
      status = false
    ensure
      #アーカイブログ出力　
      o.leave_log(msg_hash)
      return status 
    end
  end

end

#debugcode: 
#Lgdis::ExtOut::SOAP_KJcommons.send_message({"mailing_list_name" => "ktakami@di-system.co.jp", "title" => "TEST-title", "message" => "sss漢字"}, false)

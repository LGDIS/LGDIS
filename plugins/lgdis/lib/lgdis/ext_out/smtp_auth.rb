# -*- encoding: utf-8 -*-
class Lgdis::ExtOut::SMTP_Auth  < ActiveRecord::Base
  def self.send_message(msg_hash, test_flg)
    modulename="SMTP_auth"
    o = IfCommon.new
    
    #hash below is a dummy hash before integration testing
    mailing_list_name = msg_hash["mailing_list_name"]
    title = msg_hash["title"]
    message = msg_hash["message"]
    str= "////////////////////SMTPAUTH: ML/T/MSG=" + mailing_list_name + " " + title + " " + message 
    Rails.logger.info("{#{str}");print("#{str}")

    begin
      if test_flg.blank?
      # ② 自治体職員向け SMTP I/F を呼び出す。
         #@mail=Lgdis::ExtOut::Mailer.setup_auth(mailing_list_name, title, message, "utf-8", "root@localhost.localdomain", "apl", "JBC03142")  
         @mail=Lgdis::ExtOut::Mailer.setup_auth(mailing_list_name, title, message, "ISO2022-JP", "root@localhost.localdomain", "apl", "JBC03142")  
         @mail.deliver
      end
      # TODO アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      Rails.logger.info("#{o.create_log_time(msg_hash,modulename)}")
      o.leave_log(msg_hash)
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

#irb/コンソールからの呼び出しコマンド例: 
#@mail=Lgdis::ExtOut::Mailer.setup_auth( "root@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1", "utf-8", "root@localhost.localdomain", "apl", "JBC03142").deliver
#Lgdis::ExtOut::SMTP_Auth.send_message({"mailing_list_name" =>"apl@localhost.localdomain", "title" => "13", "message" =>"sss漢"},false)

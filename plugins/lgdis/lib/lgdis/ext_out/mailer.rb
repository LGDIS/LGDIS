# -*- encoding: utf-8 -*-
#require 'nkf'
class Lgdis::ExtOut::Mailer < ActionMailer::Base

  def setup(mailing_list_name, title, message) 
    begin
			#SMTP-plain
      str= "■SMTP-PLAIN: ML/T/MSG=" + mailing_list_name + " " + title + " " + message 
      mail(
        :from     => "root@localhost.localdomain",
        :to       => mailing_list_name.to_s , 
        :subject  => title.to_s ,
        :body     => message.to_s ,
        :charset  => "utf-8"
      )


			Rails.logger.info("{#{str}");print("#{str}")
      status = true
			return mail
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" )
      status = false
      return status
    ensure
    end
  end

  def setup_auth(mailing_list_name, title, message ) 
    begin
			#SMTP-AUTH
      str= "■SMTPAUTH: ML/T/MSG=" + mailing_list_name + " " + title + " " + message 
      
      ActionMailer::Base.smtp_settings = 
      { :address        => 'localhost.localdomain',
        :port           => 25,
        :domain         => 'localdomain',
        :authentication => :login ,
        :user_name      => "apl" ,
        :password       => "JBC03142"
      }

      mail(
        :from     => "root@localhost.localdomain", 
        :to       => mailing_list_name , 
        :subject  => title ,
        :body     => message ,
        :charset  => "utf-8" 
      )
			Rails.logger.info("{#{str}");print("#{str}")
      status = true
			return mail
    rescue => e
      status = false
      Rails.logger.error("#{e.backtrace.join("\n")}" )
    ensure
      return status
    end
  end
end

if __FILE__ == $0
  SetupXML.arrange_and_put
end


#予備コード
#       mail.body.charset = 'iso-2022-jp' 
#       mail.body = mail.body.raw_source.encode('ISO-2022-JP', :invalid => :replace, :undef => :replace).encode('UTF-8')
#irb/コンソールからの呼び出しコマンド例: 
# @mail=Lgdis::ExtOut::Mailer.setup_auth( "root@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1", "utf-8", "root@localhost.localdomain", "apl", "JBC03142").deliver
# @mail=Lgdis::ExtOut::Mailer.setup_auth( "apl@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1", "utf-8", "apl@localhost.localdomain", "apl", "JBC03142").deliver
# @mail=     Lgdis::ExtOut::Mailer.setup( "apl@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1", "utf-8", "apl@localhost.localdomain"                   ).deliver
# Lgdis::ExtOut::SMTP_Auth.send_message({"mailing_list_name" => "apl@localhost.localdomain", "title" => "TEST3iAUTH", "message" => "sss漢字"}, false)

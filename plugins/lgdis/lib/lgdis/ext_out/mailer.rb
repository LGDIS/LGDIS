# -*- encoding: utf-8 -*-
class Lgdis::ExtOut::Mailer < ActionMailer::Base
#   default :from           => "root@localhost.localdomain"
#   default :charset        => "utf-8"
  default :encoding       =>  'iso-2022-jp'
#   default :smtp_settings  => ""
#   default :mime_type => "text"


  def setup(mailing_list_name, title, message, charset, from)
    begin
			#SMTP-plain
      str= "■SMTP-PLAIN: ML/T/MSG=" + mailing_list_name + " " + title + " " + message 
      mail(
        :from     => from , 
        :to       => mailing_list_name , 
        :subject  => title ,
        :body     => message ,
        :charset  => charset
      )
      Rails.logger.info("{#{str}");print("#{str}")
#       status = true
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" )
#       status = false
    ensure
#       return status
    end
  end

  def setup_auth(mailing_list_name, title, message, charset, from, smtp_username, smtp_password, gmailoption=nil)
    begin
			#SMTP-AUTH
      str= "■SMTPAUTH: ML/T/MSG=" + mailing_list_name + " " + title + " " + message 
      ActionMailer::Base.smtp_settings = 
      { :address        => 'localhost.localdomain',
        :port           => 25,
        :domain         => 'localdomain',
        :authentication => :login ,
        :user_name      => smtp_username ,
        :password       => smtp_password
      }

      mail(
        :from     => from , 
        :to       => mailing_list_name , 
        :subject  => title ,
        :body     => message ,
        :charset  => charset 
      )
      Rails.logger.info("{#{str}");print("#{str}")
#       status = true
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" )
#       status = false
    ensure
#       return status
    end
  end
#   print mail.body
end


#irb/コンソールからの呼び出しコマンド例: 
# @mail=Lgdis::ExtOut::Mailer.setup_auth( "root@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1", "utf-8", "root@localhost.localdomain", "apl", "JBC03142").deliver
# @mail=Lgdis::ExtOut::Mailer.setup_auth( "apl@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1", "utf-8", "apl@localhost.localdomain", "apl", "JBC03142").deliver
# @mail=     Lgdis::ExtOut::Mailer.setup( "apl@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1", "utf-8", "apl@localhost.localdomain"                   ).deliver
# Lgdis::ExtOut::SMTP_Auth.send_message({"mailing_list_name" => "apl@localhost.localdomain", "title" => "TEST3iAUTH", "message" => "sss漢字"}, false)

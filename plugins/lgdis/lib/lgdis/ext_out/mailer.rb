# -*- encoding: utf-8 -*-
class Lgdis::ExtOut::Mailer < ActionMailer::Base
  #外部出力機能共通のメール整形送信送メソッドを未作成 k-takami
  default :from           => "root@localhost.localdomain"
  default :charset        => "utf-8"
#   default :encoding       =>  'iso-2022-jp'
#   default :smtp_settings  => ""
#   default :mime_type => "text"


  def setup(mailing_list_name, title, message, charset, from)
    puts "■SMTP-PLAIN: ML/T/MSG=" + mailing_list_name + " " + title + " " + message

    mail(
      :to       => mailing_list_name ,
      :from     => from,
      :subject  => title ,
      :body     => message ,
      :charset  => charset
    )
  end

  def setup_auth(mailing_list_name, title, message, charset, from, smtp_username, smtp_password)
    puts "■SMTP-AUTH:  ML/T/MSG=" + mailing_list_name + " " + title + " " + message
#    debugger
    ActionMailer::Base.smtp_settings =
    {
      :enable_starttls_auto => true,
      :address        => 'smtp.gmail.com',
      :port           => 587,
      :domain         => 'smtp.gmail.com',
      :authentication => :plain ,
      :user_name      => '' ,
      :password       => ''
    }
    mail(
      :to       => mailing_list_name ,
      :from     => from,
      :subject  => title ,
      :body     => message ,
      :charset  => charset
    )
  end
#   print mail.body
end

#irb/コンソールからの呼び出しコマンド例: 
# @mail=Lgdis::ExtOut::Mailer.setup_auth( "root@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1", "utf-8", "root@localhost.localdomain", "apl", "JBC03142").deliver
# @mail=Lgdis::ExtOut::Mailer.setup_auth( "apl@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1", "utf-8", "apl@localhost.localdomain", "apl", "JBC03142").deliver
# @mail=     Lgdis::ExtOut::Mailer.setup( "apl@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1", "utf-8", "apl@localhost.localdomain", "apl", "JBC03142").deliver
# Lgdis::ExtOut::SMTP_Auth.send_message({"mailing_list_name" => "apl@localhost.localdomain", "title" => "TEST3iAUTH", "message" => "sss漢字"}, false)

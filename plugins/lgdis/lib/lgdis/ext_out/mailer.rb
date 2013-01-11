# -*- encoding: utf-8 -*-
# encoding: utf-8
class Lgdis::ExtOut::Mailer < ActionMailer::Base
  #外部出力機能共通のメール整形送信送メソッドを未作成 k-takami
  default :from           => "root@localhost.localdomain"
  default :charset        => "utf-8"
#   default :encoding       =>  'iso-2022-jp'
#   default :smtp_settings  => ""
#   default :mime_type => "text"

  def setup(ml, title, message, charset, from)
    mail(
      :to       => ml , 
      :subject  => title ,
      :body     => message ,
      :charset  => charset
    )
  end

  def setup_auth(ml, title, message, charset, from, username, password)
    ActionMailer::Base.smtp_settings = 
    { :address        => 'localhost.localdomain',
      :port           => 25,
      :domain         => 'localdomain',
      :user_name      => 'apl',
      :password       => 'JBC03142',
      :authentication => :login
    }
    mail(
      :to       => ml , 
      :subject  => title ,
      :body     => message ,
      :charset  => charset ,
      :username  => username ,
      :password  => password
    )
  end
#   print mail.body
end

#irb/コンソールからの呼び出しコマンド例: 
#mail=Lgdis::ExtOut::Mailer.setup("root@localhost.localdomain","共通出力", "本文に漢字", "utf-8", "root@localhost.localdomain").deliver



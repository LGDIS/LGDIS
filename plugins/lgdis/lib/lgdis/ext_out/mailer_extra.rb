# -*- encoding: utf-8 -*-
# SMTP Plain/AUTH メールをメモリー空間に作るクラス｡
# 設定はRails.root/plugins/lgdis/config/destination_list.ymlで行う｡

class Lgdis::ExtOut::MailerExtra < ActionMailer::Base
  # 例外的通報用SMTP-plain(認証なしSMTP)サーバーむけメールインスタンスを生成する｡
  # ==== Args
  # _mailing_list_name_ :: 送信先メールアドレス
  # _title_ :: eメール件名
  # _message_ :: eメール本文
  # ==== Return
  # __ :: 正常終了はMail::Message クラス､異常終了はfalseを返す｡
  # ==== Raise
  def setup(mailing_list_name, title, message)
    begin
      #SMTP-plain
      str= "■SMTP-PLAIN: ML/T/MSG=" + mailing_list_name + " " + title + " " + message 

      fromname = DST_LIST['smtp_server3']['fromname']
      charset= DST_LIST['smtp_server3']['charset']
      port = DST_LIST['smtp_server3']['port']
      mta_fqdn = DST_LIST['smtp_server3']['mta_fqdn']
      domain = DST_LIST['smtp_server3']['domain']
        fromname = "root@localhost.localdomain" if fromname.blank? 
        charset = "root@localhost.localdomain" if charset.blank? 
        port = 25 if port.blank?  
        mta_fqdn = 'localhost.localdomain' if mta_fqdn.blank?  
        domain = "localdomain" if domain.blank?  

      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.raise_delivery_errors = true
      ActionMailer::Base.smtp_settings = 
      { :address        => mta_fqdn,
        :port           => port,
        :domain         => domain
      }
      mail(
        :from     => fromname,
        :to       => mailing_list_name.to_s , 
        :subject  => title.to_s,
        :body     => message.to_s ,
        :charset  => 'utf-8'
      )

      Rails.logger.info("{#{str}");print("#{str}")
      status = true
      return mail(:subject => title.to_s)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" )
      status = false
      return status
    ensure
    end
  end

  # 例外的通報用SMTP-AUTH(認証ありMTP)サーバーむけメールインスタンスを生成する｡
  # ==== Args
  # _mailing_list_name_ :: 送信先メールアドレス
  # _title_ :: eメール件名
  # _message_ :: eメール本文
  # ==== Return
  # __ :: 正常終了はMail::Message クラス､異常終了はfalseを返す｡
  # ==== Raise
  def setup_auth(mailing_list_name, title, message)
    begin
      #SMTP-AUTH
      str= "■SMTPAUTH: ML/T/MSG=" + mailing_list_name + " " + title + " " + message 
      
      fromname = DST_LIST['smtp_server3']['fromname']
      charset= DST_LIST['smtp_server3']['charset']
      port = DST_LIST['smtp_server3']['port']
      mta_fqdn = DST_LIST['smtp_server3']['mta_fqdn']
      domain = DST_LIST['smtp_server3']['domain']
      account = DST_LIST['smtp_server3']['account']
      pw = DST_LIST['smtp_server3']['password']
        fromname = "root@localhost.localdomain" if fromname.blank? 
        charset = "root@localhost.localdomain" if charset.blank? 
        port = 25 if port.blank?  
        mta_fqdn = 'localhost.localdomain' if mta_fqdn.blank?  
        domain = "localdomain" if domain.blank?  
        account = "apl" if account.blank?  
        pw = "JBC03142" if pw.blank?  

      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.raise_delivery_errors = true
      ActionMailer::Base.smtp_settings = 
      { :address        => mta_fqdn,
        :port           => port,
        :domain         => domain,
        :authentication => :login ,
        :user_name      => account,
        :password       => pw
      }

      mail(
        :from     => fromname,
        :to       => mailing_list_name.to_s , 
        :subject  => title.to_s,
        :body     => message.to_s ,
        :charset  => charset
      )

      Rails.logger.info("{#{str}");print("#{str}")
      status = true
      return mail(:subject => title.to_s)
    rescue => e
      status = false
      Rails.logger.error("#{e.backtrace.join("\n")}" )
      return status
    ensure
    end
  end

end



#予備コード
#       mail.body.charset = 'iso-2022-jp' 
#       mail.body = mail.body.raw_source.encode('ISO-2022-JP', :invalid => :replace, :undef => :replace).encode('UTF-8')
#irb/コンソールからの呼び出しコマンド例: 
# @mail=Lgdis::ExtOut::Mailer.setup_auth( "root@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1").deliver
# @mail=Lgdis::ExtOut::Mailer.setup_auth( "apl@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1").deliver
# @mail=     Lgdis::ExtOut::Mailer.setup( "apl@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1").deliver
# Lgdis::ExtOut::SMTP_Auth.send_message({"mailing_list_name" => "apl@localhost.localdomain", "title" => "TEST3iAUTH", "message" => "sss漢字"}, false)

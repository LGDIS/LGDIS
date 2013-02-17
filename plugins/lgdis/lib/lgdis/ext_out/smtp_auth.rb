# -*- encoding: utf-8 -*-
# 認証付きSMTP送信(SMTP-AUTH)の送信処理wrapperプログラム
class Lgdis::ExtOut::SmtpAuth  < ActiveRecord::Base

  # SMTP送信処理プログラム本体をよびだし
  # ==== Args
  # _msg_ :: 送信先､題名､メッセージ本文をふくんだハッシュ(=連想配列)
  # _test_flg_ :: 試験モードフラグ
  # ==== Return
  # _status_ :: 正常終了はMail::Message クラス､異常終了はfalseを返す｡
  # ==== Raise
  def self.send_message(msg, test_flg)
    modulename="SMTP_auth"
    o = IfCommon.new
    mailing_list_name = msg["mailing_list_name"]
    title = msg["title"]
    message = msg["message"]

    str= "///////////SMTPAUTH: ML/T/MSG=" + mailing_list_name + " " + title + " " + message 
    Rails.logger.info("{#{str}");print("#{str}")

    begin
      if test_flg.blank?
      # SMTP-plainむけのヘッダーを生成直後､deliveryメソッドで一気に送信する。
        status=Lgdis::ExtOut::Mailer.setup_auth(mailing_list_name, title, message ).deliver
      end
      # TODO アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      Rails.logger.info("#{o.create_log_time(msg,modulename)}")
      o.leave_log(msg)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{o.create_log_time(msg,modulename)}")
      status = false
      # エラー時のメール配信 -> if_common.rbのメソッドを呼び出す
      o.mail_when_delivery_fails
    ensure
      #アーカイブログ出力　  -> if_common.rbのメソッドを呼び出す
      o.leave_log(msg);print "\n"
      return status 
    end
  end
end












#irb/コンソールからの呼び出しコマンド例: 
#@mail=Lgdis::ExtOut::Mailer.setup_auth( "root@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1", "utf-8", "root@localhost.localdomain", "apl", "JBC03142").deliver
#Lgdis::ExtOut::SMTP_Auth.send_message({"mailing_list_name" =>"apl@localhost.localdomain", "title" => "13", "message" =>"sss漢"},false)

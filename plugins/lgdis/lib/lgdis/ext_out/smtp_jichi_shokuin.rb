# -*- encoding: utf-8 -*-
# 認証なしSMTP送信プログラムwrapper
class Lgdis::ExtOut::SMTP_JichiShokuin  < ActiveRecord::Base
  # 認証なしSMTP送信プログラムwrapper
  # ==== Args
  # _msg_ :: 送信先､表題､メッセージ本文を含んだハッシュ(=連想配列)
  # _test_flg_ :: 試験モードフラグ
  # _issue_ :: Redmineチケット
  # ==== Return
  # _status_ :: 正常終了はMail::Message クラス､異常終了はfalseを返す｡
  # ==== Raise
  def self.send_message(msg, test_flg)
    modulename="JichiShokuin"
    o = IfCommon.new
    mailing_list_name = msg["mailing_list_name"]
    title = msg["title"]
    message = msg["message"]

    begin
      if test_flg.blank?
      # 自治体職員向け SMTP-AUTH生成プログラムを呼びだし､送信する。
        status = @mail=Lgdis::ExtOut::Mailer.setup(mailing_list_name, title, message).deliver
      end
      #TODO: アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      Rails.logger.info("#{o.create_log_time(msg,modulename)}")
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{o.create_log_time(msg,modulename)}")
      status = false
    ensure
      #アーカイブログ出力　
      o.leave_log(msg)
      return status 
    end
  end
end























#debugcode  
# raise #=> RuntimeError:
#p ls -alt  /root/Maildir/new/*
#  @mail=Lgdis::ExtOut::Mailer.setup("root@localhost.localdomain", "引数0例 共通出力", "引数1例 本文に漢字", "utf-8", "root@localhost.localdomain").deliver
#  @mail=Lgdis::ExtOut::SMTP_JichiShokuin.send_message({"mailing_list_name" =>"root@localhost.localdomain", "title" => "TEST-title漢字", "message" =>"sss漢字"}, false)
#  Lgdis::ExtOut::Mailer.setup("ktakami@di-system.co.jp", "引数0例 共通", "//////////////", "utf-8", "ktakami@di-system.co.jp").deliver
#  @mail= Lgdis::ExtOut::SMTP_JichiShokuin.send_message({"mailing_list_name" =>"ktakami@di-system.co.jp", "title" => "title漢字", "message" =>"sss漢字-------------"}, false)
#targetUser = User.find_by_mail("root@localhost.localdomain")


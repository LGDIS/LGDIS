# -*- encoding: utf-8 -*-
class Lgdis::ExtOut::SMTP_JichiShokuin  < ActiveRecord::Base
  def self.send_message(msg_hash, test_flg)
    modulename="JichiShokuin"
    o = IfCommon.new
    #hash below is a dummy hash before integration testing: k-takami 
    mailing_list_name = msg_hash["mailing_list_name"]
    title = msg_hash["title"]
    message = msg_hash["message"]

    begin
      if test_flg.blank?
          #TODO: p "////////ML-TITLE-MSG//////////////////" + mailing_list_name + " " + title + " " + message #k-takami SMTP-AUTH
          @mail=Lgdis::ExtOut::Mailer.setup(mailing_list_name, title, message, "utf-8", "root@localhost.localdomain") 
          @mail.deliver
      end
      # TODO
      # アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      # ① rake タスクとして、配信要求キューを取得するワーカーを起動する。
      # ② 自治体職員向け SMTP I/F を呼び出す。
      Rails.logger.info("#{o.create_log_time(msg_hash,modulename)}")
      #k-takami アーカイブログ出力例:　
      o.leave_log(msg_hash)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{o.create_log_time(msg_hash,modulename)}")
    ensure
      # TODO 配信管理側に処理完了ステータスを通知する必要あり
    end
  end
end
#
#debugcode  
#p ls -alt  /root/Maildir/new/*
#  @mail=Lgdis::ExtOut::Mailer.setup("root@localhost.localdomain", "引数0例 共通出力", "引数1例 本文に漢字", "utf-8", "root@localhost.localdomain").deliver
#  @mail=Lgdis::ExtOut::SMTP_JichiShokuin.send_message({"mailing_list_name" =>"root@localhost.localdomain", "title" => "TEST-title漢字", "message" =>"sss漢字"}, false)
#  Lgdis::ExtOut::Mailer.setup("ktakami@di-system.co.jp", "引数0例 共通", "//////////////", "utf-8", "ktakami@di-system.co.jp").deliver
#  @mail= Lgdis::ExtOut::SMTP_JichiShokuin.send_message({"mailing_list_name" =>"ktakami@di-system.co.jp", "title" => "title漢字", "message" =>"sss漢字-------------"}, false)
#targetUser = User.find_by_mail("root@localhost.localdomain")


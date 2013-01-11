# -*- encoding: utf-8 -*-
# encoding: utf-8
class Lgdis::ExtOut::SMTP_JichiShokuin  < ActiveRecord::Base
  def self.send_message(msg, test_flg)
    modulename="JichiShokuin"
    o = IfCommon.new
    begin
      if test_flg.blank?
          #mailing_list_name=msg[0]; title=msg[1];  message=msg[2]
          targetUser = User.find_by_mail("root@localhost.localdomain")
          @mail=Lgdis::ExtOut::Mailer.setup("root@localhost.localdomain", "引数0例 共通出力", "引数1例 本文に漢字", "utf-8", "root@localhost.localdomain").deliver
          #TODO 1/12の現時点で､配信管理機能からのI/Fがつくられていないので､ダミーのメールを生成しています｡  k-takami
          #@test = Mailer.test_email(targetUser).deliver
      end
      # TODO
      # アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      # ① rake タスクとして、配信要求キューを取得するワーカーを起動する。
      # ② 自治体職員向け SMTP I/F を呼び出す。
      Rails.logger.info("#{o.create_log_time(msg,modulename)}")
      #k-takami アーカイブログ出力例:　
      o.leave_log(msg)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{o.create_log_time(msg,modulename)}")
    ensure
      # TODO 配信管理側に処理完了ステータスを通知する必要あり
    end
  end
end
#
#debugcode  
#p User.find_by_mail("root@localhost.localdomain")
#p ls -alt  /root/Maildir/new/*
#Lgdis::ExtOut::SMTP_JichiShokuin.send_message("22222222222222222\n", false)
#@test = Mailer.issue_add(targetUser).deliver

# -*- encoding: utf-8 -*-
# encoding: utf-8
class Lgdis::ExtOut::SMTP_auth  < ActiveRecord::Base
  def self.send_message(msg, test_flg)
    modulename="SMTP_auth"
    o = IfCommon.new
    begin
      if test_flg.blank?
          #mailing_list_name=msg[0]; title=msg[1];  message=msg[2]
          targetUser = User.find_by_mail("root@localhost.localdomain")
          @mail=Lgdis::ExtOut::Mailer.setup_auth(
            "root@localhost.localdomain","SMTP-AUTH引数0", "SMTP-AUTH引数1", "utf-8", "root@localhost.localdomain", "apl", "JBC03142"
          ).deliver
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
      # TODO
      # 配信管理側に処理完了ステータスを通知する必要あり
    end
  end
end

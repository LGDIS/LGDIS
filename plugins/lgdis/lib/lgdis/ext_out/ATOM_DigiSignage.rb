# -*- encoding: utf-8 -*-
# encoding: utf-8
class Lgdis::ExtOut::ATOM_DigiSignage  < ActiveRecord::Base
  def self.send_message(msg, test_flg)
    modulename="DigiSignage"
    o = IfCommon.new

    begin
      if test_flg.blank?
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
      # 配信管理側に処理完了ステータスを
      # 通知する必要あり
    end
  end

end

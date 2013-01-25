# -*- encoding: utf-8 -*-
class Lgdis::ExtOut::ATOM_DigiSignage  < ActiveRecord::Base
  def self.send_message(msg_hash, test_flg)
    modulename="DigiSignage"
    o = IfCommon.new

    begin
      if test_flg.blank?
        #配信管理画面で生成されたATOM型式geoRSSファイル又はそのオブジェクトを､
        #仕様確定後､なんらかの方法で災害情報ポータル デジタルサイネージサーバーに渡す｡
        #ATOM生成URL例:     http://192.168.18.130:3000/projects.atom?key=6724553250c556a08a5ff4a76724d8b5ed1c3a45
  #      SetupXML.arrange_and_put(msg)
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
      # TODO
      # 配信管理側に処理完了ステータスを通知する必要あり
    end
  end

end

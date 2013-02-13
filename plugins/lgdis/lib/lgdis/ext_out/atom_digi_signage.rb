# -*- encoding: utf-8 -*-
# simple-geoRSS(ATOM1.0)生成I/Fよびだしワーカー
#Railsコンソールから呼ぶ場合は､RedmineのIssueオブジェクトを引数にして以下の様に呼び出す;
#  例: Lgdis::ExtOut::ATOM_DigiSignage.send_message(Issue.all[1], false)
class Lgdis::ExtOut::ATOM_DigiSignage  < ActiveRecord::Base
  def self.send_message(msg, test_flg)
    modulename="DigiSignage"
    o = IfCommon.new
    begin
      if test_flg.blank?
        #配信管理画面で生成されたATOM型式geoRSSファイル又はそのオブジェクトを､
        #仕様確定後､なんらかの方法で災害情報ポータル デジタルサイネージサーバーに渡す｡
        #ATOM生成URL例: http://192.168.18.130:3000/projects.atom?key=6724553250c556a08a5ff4a76724d8b5ed1c3a45
        SetupXML.arrange_and_put(msg)
      end
      #TODO: アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      Rails.logger.info("#{o.create_log_time(msg,modulename)}")
      status = true
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

# -*- encoding: utf-8 -*-
# simple-geoRSS(ATOM1.0)生成プログラムwrapper
# Railsコンソールから呼ぶ場合は､RedmineのIssueオブジェクトを引数にして以下の様に呼び出す;
#  例: Lgdis::ExtOut::ATOM_DigiSignage.send_message(Issue.all[1], false)
class Lgdis::ExtOut::ATOM_DigiSignage  < ActiveRecord::Base

  # geoRSS(ATOM1.0)生成プログラムwよびだし処理
  # 最後にログ出力を行い､戻り値を返す
  # ==== Args
  # _msg_ :: Redmineチケット
  # _test_flg_ :: 試験モードフラグ
  # ==== Return
  # _status_ :: 戻り値
  # ==== Raise
  def self.send_message(msg, test_flg)
    modulename="DigiSignage"
    o = IfCommon.new
    begin
      if test_flg.blank?
        # 配信管理画面で生成されたATOM形式simple-geoRSSファイルを
        # Rails.root/public/atom/*.rdf として出力する｡
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
      # アーカイブログ出力　
      o.leave_log(msg)
      return status 
    end
  end

end

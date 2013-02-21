# -*- encoding: utf-8 -*-
# simple-geoRSS(ATOM1.0)生成プログラムwrapper
# Railsコンソールから呼ぶ場合は､RedmineのIssueオブジェクトを引数にして以下の様に呼び出す;
#  例: Lgdis::ExtOut::ATOM_DigiSignage.send_message(Issue.all[1], false)
class Lgdis::ExtOut::AtomDigiSignage  < ActiveRecord::Base

  # geoRSS(ATOM1.0)生成プログラムwよびだし処理
  # 最後にログ出力を行い､戻り値を返す
  # ==== Args
  # _msg_ :: Redmineチケット
  # _test_flg_ :: 試験モードフラグ
  # ==== Return
  # _status_ :: 戻り値
  # ==== Raise
  def self.send_message(msg, test_flg, draft_flg=true)
    modulename="DigiSignage"
    o = IfCommon.new
    begin
      if test_flg.blank?
        # 配信管理画面で生成されたATOM形式simple-geoRSSファイルを
        # Rails.root/public/atom/*.rdf として出力する｡
        status = SetupXML.arrange_and_put(msg,nil, draft_flg)
      end
      #TODO: アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      Rails.logger.info("#{o.create_log_time(msg,modulename)}")
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

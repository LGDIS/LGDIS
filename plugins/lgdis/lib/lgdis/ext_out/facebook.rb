# -*- encoding: utf-8 -*-
# Facebook投稿処理I/Fプログラム
class Lgdis::ExtOut::Facebook < ActiveRecord::Base

  # Facebook投稿処理
  # 最後にログ出力をし､戻り値を返す
  #
  # 処理中にエラーがあれば､destination_list.ymlで設定された
  # SMTPサーバーとalert先にメール通知をする
  # ==== Args
  # _msg_ :: 送信先､表題､メッセージ本文を含んだハッシュ(=連想配列)
  # _test_flg_ :: 試験モードフラグ
  # ==== Return
  # _status_ :: 戻り値
  # ==== Raise
  def self.send_message(msg, test_flg)
    modulename="Facebook"
    o = IfCommon.new
    begin
      if test_flg.blank?
        @graph = Koala::Facebook::API.new(API_KEY['facebook']['app_token'])
        @graph.put_connections(API_KEY['facebook']['user_id'], "feed", :message => msg)
      end

      #TODO: アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      Rails.logger.info("#{o.create_log_time(msg, modulename)}")
      o.leave_log(msg)
      status = true
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{o.create_log_time(msg, modulename)}")
      status = false
      # エラー時のメール配信 -> if_common.rbのメソッドを呼び出す
      o.mail_when_delivery_fails
    ensure
      #アーカイブログ出力　  -> if_common.rbのメソッドを呼び出す
      o.leave_log(msg)
       print "\n"
      return status 
    end
  end

end

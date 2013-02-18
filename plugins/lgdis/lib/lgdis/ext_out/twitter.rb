# -*- encoding: utf-8 -*-
# twitterへの投稿をするクラス
class Lgdis::ExtOut::Twitter < ActiveRecord::Base

  # twitterへの投稿をするクラス
  # 最後にログ出力をし､戻り値を返す
  # 処理中にエラーがあれば､destination_list.ymlで設定された
  # SMTPサーバーに接続しalert先へのメール通知を試みる
  # ==== Args
  # _msg_ :: 送信先､表題､メッセージ本文を含んだハッシュ(=連想配列)
  # _test_flg_ :: 試験モードフラグ
  # _issue_ :: Redmineチケット
  # ==== Return
  # _status_ :: 戻り値
  # ==== Raise
  def self.send_message(msg, test_flg)
    modulename="Twitter"
    o = IfCommon.new
    begin
      if test_flg.blank?
        Twitter.configure do |config|
          config.consumer_key    = API_KEY['twitter']['consumer_key']
          config.consumer_secret = API_KEY['twitter']['consumer_secret']
          config.oauth_token     = API_KEY['twitter']['oauth_token']
          config.oauth_token_secret = API_KEY['twitter']['oauth_token_secret']
        end
        Twitter.update(msg)
      end

      #TODO: アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      Rails.logger.info("#{o.create_log_time(msg, modulename)}")
      status = true
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{o.create_log_time(msg, modulename)}")
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

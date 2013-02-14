# -*- encoding: utf-8 -*-
# Facebook投稿処理I/Fプログラムをよびだす非同期処理ワーカー
class FacebookRequestJob
  @queue = :facebook_request

  # Facebook投稿プログラムよびだし処理 非同期処理にはResqueを使用
  # ==== Args
  # _msg_ :: 送信先､題名､メッセージ本文をふくんだハッシュ(=連想配列)
  # _test_flg_ :: 試験モードフラグ
  # _issue_ :: Redmineチケット
  # ==== Return
  # _status_ :: 戻り値
  # ==== Raise
  def self.perform(msg, test_flg, issue)
    begin
      str= "##################################### Facebook-WORKER がよばれました\n"
      Rails.logger.info("{#{str}");print("#{str}")
      status = Lgdis::ExtOut::Facebook.send_message(msg, test_flg)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}\n")
      status = false
    ensure
      return status
    end
  end
end


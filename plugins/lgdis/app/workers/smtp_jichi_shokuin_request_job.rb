# -*- encoding: utf-8 -*-
# 認証なしSMTP送信(SMTP-plain)のwrapperをよびだす非同期処理ワーカー
class SMTP_JichiShokuinRequestJob
  @queue = :smtp_jichi_shokuin_request
  # 認証なしSMTP送信プログラムwrapperよびだし処理 非同期処理にはResqueを使用
  # 最後に戻り値を返す
  # ==== Args
  # _msg_ :: 送信先､表題､メッセージ本文を含んだハッシュ(=連想配列)
  # _test_flg_ :: 試験モードフラグ
  # _issue_ :: Redmineチケット
  # ==== Return
  # _status_ :: 正常終了はMail::Message クラス､異常終了はfalseを返す｡
  # ==== Raise
  def self.perform(msg, test_flg, issue)
    begin
      str= "##################################### SMTP-PLAIN-WORKER がよばれました\n" 
      Rails.logger.info("{#{str}");print("#{str}")
      status =  Lgdis::ExtOut::SMTP_JichiShokuin.send_message(msg, test_flg)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}\n")
      status = false
    ensure
      return status
    end
  end
end

































#debugcode
# raise #=> RuntimeError:
# SMTP_JichiShokuinRequestJob.perform({"mailing_list_name" =>"root@localhost.localdomain", "title" => "TEST-title漢字", "message" =>"sss漢字"}, false)
# Lgdis::ExtOut::SMTP_JichiShokuin.send_message({"mailing_list_name" =>"root@localhost.localdomain", "title" => "TEST-title漢字", "message" =>"sss漢字"}, false)

# -*- encoding: utf-8 -*-
# 認証付きSMTP送信(SMTP-AUTH)のI/Fをよびだす非同期処理ワーカー
class SMTP_AuthRequestJob
  @queue = :smtp_auth_request

  # I/Fよびだし処理 非同期処理にはResqueを使用
  # ==== Args
  # _msg_ :: 送信先､題名､メッセージ本文をふくんだハッシュ(=連想配列)
  # _test_flg_ :: 試験モードフラグ
  # _issue_ :: Redmineチケット
  # ==== Return
  # _status_ :: 正常終了はMail::Message クラス､異常終了はfalseを返す｡
  # ==== Raise
  def self.perform(msg, test_flg, issue)
    begin
      str= "##################################### SMTP-AUTH-WORKER がよばれました\n"
      Rails.logger.info("{#{str}");print("#{str}")
      status = Lgdis::ExtOut::SMTP_Auth.send_message(msg, test_flg)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}\n")
      status = false
    ensure
      return status
    end
  end

end
































#debugcode
# SMTP_AuthRequestJob.perform({"mailing_list_name" =>"root@localhost.localdomain", "title" => "TEST-title漢字"}, false)
# SMTP_AuthRequestJob.perform({"mailing_list_name" =>"root@localhost.localdomain", "title" => "TEST-title漢字", "message" =>"sss漢字"}, false)



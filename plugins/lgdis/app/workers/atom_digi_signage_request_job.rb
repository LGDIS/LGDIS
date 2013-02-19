# coding: utf-8
# simple-geoRSS(ATOM1.0)生成I/Fをよびだす非同期処理ワーカー
class AtomDigiSignageRequestJob
  @queue = :atom_digi_signage_request

  # I/Fよびだし処理 非同期処理にはResqueを使用
  # ==== Args
  # _msg_ :: Redmineチケット
  # _test_flg_ :: 試験モードフラグ
  # ==== Return
  # _status_ :: 戻り値
  # ==== Raise
  def self.perform(msg, test_flg, issue, delivery_history=nil, draft_flg=true)
    o = IfCommon.new
    begin
      str= "##################################### 災害情報ポータルWORKER がよばれました\n"
      Rails.logger.info("{#{str}");print("#{str}")
      status = Lgdis::ExtOut::AtomDigiSignage.send_message(msg, test_flg,draft_flg)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}\n")
      status = false
      # エラー時のメール配信 -> if_common.rbのメソッドを呼び出す
      o.mail_when_delivery_fails
    ensure
      #アーカイブログ出力　  -> if_common.rbのメソッドを呼び出す
      o.leave_log(msg); print "\n"
      o.register_edition(issue) if status != false
      o.feedback_to_issue_screen(msg, issue, delivery_history, status)
      return status
    end
  end
end































#debugcode
# Atom_DigiSignageRequestJob.perform({"mailing_list_name" =>"root@localhost.localdomain", "title" => "TEST-title漢字"}, false)
# Atom_DigiSignageRequestJob.perform({"mailing_list_name" =>"root@localhost.localdomain", "title" => "TEST-title漢字", "message" =>"sss漢字"}, false)



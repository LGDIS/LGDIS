# coding: utf-8
# simple-geoRSS(ATOM1.0)生成I/Fをよびだす非同期処理ワーカー
class Atom_DigiSignageRequestJob
  @queue = :atom_digi_signage_request

  # I/Fよびだし処理 非同期処理にはResqueを使用
  # ==== Args
  # _msg_ :: Redmineチケット
  # _test_flg_ :: 試験モードフラグ
  # ==== Return
  # _status_ :: 戻り値
  # ==== Raise
  def self.perform(msg_hash, test_flg, issue)
    begin
      str= "##################################### 災害情報ポータルWORKER がよばれました\n"
      Rails.logger.info("{#{str}");print("#{str}")

      status = Lgdis::ExtOut::Atom_DigiSignage.send_message(msg_hash, test_flg)

    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}\n")
      status = false
    ensure
      return status
    end
  end
end































#debugcode
# Atom_DigiSignageRequestJob.perform({"mailing_list_name" =>"root@localhost.localdomain", "title" => "TEST-title漢字"}, false)
# Atom_DigiSignageRequestJob.perform({"mailing_list_name" =>"root@localhost.localdomain", "title" => "TEST-title漢字", "message" =>"sss漢字"}, false)



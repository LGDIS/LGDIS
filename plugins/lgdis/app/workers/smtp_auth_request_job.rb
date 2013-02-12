# coding: utf-8
class SMTP_AuthRequestJob
  @queue = :smtp_auth_request

  def self.perform(msg_hash, test_flg, issue)
    begin
      str= "##################################### SMTP-AUTH-WORKER がよばれました\n"
      Rails.logger.info("{#{str}");print("#{str}")
      status = Lgdis::ExtOut::SMTP_Auth.send_message(msg_hash, test_flg)
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



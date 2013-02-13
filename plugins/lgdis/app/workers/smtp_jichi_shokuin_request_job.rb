# coding: utf-8
class SMTP_JichiShokuinRequestJob
  @queue = :smtp_jichi_shokuin_request
  def self.perform(msg_hash, test_flg, issue)
    begin
      str= "##################################### SMTP-PLAIN-WORKER がよばれました\n" 
      Rails.logger.info("{#{str}");print("#{str}")
debugger
      status =  Lgdis::ExtOut::SMTP_JichiShokuin.send_message(msg_hash, test_flg)
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

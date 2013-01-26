# coding: utf-8
class SMTP_JichiShokuinRequestJob
  @queue = :smtp_jichi_shokuin_request
p "========================================================="
  def self.perform(msg_hash, test_flg)
    str= "////////SMTP-PLAIN-WORKER: ML/TITLE/MSG="  + mailing_list_name + " " + title + " " + message #k-takami SMTP-AUTH
    Rails.logger.info("{#{str}");print("#{str}")
#     debugger
    Lgdis::ExtOut::SMTP_JichiShokuin.send_message(msg_hash, test_flg)
  end
p "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
end



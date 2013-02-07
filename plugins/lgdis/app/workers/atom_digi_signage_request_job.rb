# coding: utf-8
class Atom_DigiSignageRequestJob
  #TODO:佐藤さんに伝達:SMTP_DigiSignageRequestJob Atom_DigiSignageRequestJob
  @queue = :atom_digi_signage_request

  def self.perform(msg_hash, test_flg)
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



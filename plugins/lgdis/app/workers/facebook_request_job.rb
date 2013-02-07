# coding: utf-8
class FacebookRequestJob
  @queue = :facebook_request

  def self.perform(msg, test_flg)
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


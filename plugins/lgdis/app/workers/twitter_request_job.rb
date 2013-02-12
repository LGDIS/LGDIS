# coding: utf-8
class TwitterRequestJob
  @queue = :twitter_request

  def self.perform(msg, test_flg, issue)
    begin
      str= "##################################### Twitter-WORKER がよばれました\n"
      Rails.logger.info("{#{str}");print("#{str}")

      status = Lgdis::ExtOut::Twitter.send_message(msg, test_flg)

    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}\n")
      status = false
    ensure
      return status
    end
  end
end

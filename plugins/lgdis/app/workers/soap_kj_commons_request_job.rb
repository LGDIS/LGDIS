# coding: utf-8
class SOAP_KJcommonsRequestJob
  @queue = :soap_kj_commons_request

  def self.perform(msg_hash, test_flg)
    begin
      str= "##################################### 公共情報コモンズWORKER がよばれました\n"
      Rails.logger.info("{#{str}");print("#{str}")
      status = Lgdis::ExtOut::SOAP_KJcommons.send_message(msg_hash, test_flg)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}\n")
      status = false
    ensure
      return status 
    end
  end

end


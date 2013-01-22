# coding: utf-8
class SOAP_KJcommonsRequestJob
  @queue = :soap_kj_commons_request

  def self.perform(msg_hash, test_flg)
    Lgdis::ExtOut::SOAP_KJcommons.send_message(msg_hash, test_flg)
  end
end




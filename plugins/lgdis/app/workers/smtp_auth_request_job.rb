# coding: utf-8
class SMTP_AuthRequestJob
  @queue = :smtp_auth_request

  def self.perform(msg_hash, test_flg)
    Lgdis::ExtOut::SMTP_Auth.send_message(msg_hash, test_flg)
  end
end




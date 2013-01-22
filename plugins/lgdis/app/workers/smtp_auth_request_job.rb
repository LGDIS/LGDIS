# coding: utf-8
class SMTP_authRequestJob
  @queue = :smtp_auth_request

  def self.perform(msg_hash, test_flg)
    Lgdis::ExtOut::SMTP_auth.send_message(msg, test_flg)
  end
end




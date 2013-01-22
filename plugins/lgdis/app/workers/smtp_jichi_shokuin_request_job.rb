# coding: utf-8
class SMTP_JichiShokuinRequestJob
  @queue = :smtp_jichi_shokuin_request

  def self.perform(msg_hash, test_flg)
    Lgdis::ExtOut::SMTP_JichiShokuin.send_message(msg_hash, test_flg)
  end
end



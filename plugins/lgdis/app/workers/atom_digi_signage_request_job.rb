# coding: utf-8
class SMTP_DigiSignageRequestJob
  @queue = :atom_digi_signage_request

  def self.perform(msg_hash, test_flg)
    Lgdis::ExtOut::SMTP_DigiSignage.send_message(msg_hash, test_flg)
  end
end





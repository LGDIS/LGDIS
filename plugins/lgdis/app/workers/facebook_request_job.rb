# coding: utf-8
class FacebookRequestJob
  @queue = :facebook_request

  def self.perform(msg, test_flg)
    Lgdis::ExtOut::Facebook.send_message(msg, test_flg)
  end
end


# coding: utf-8
class TwitterRequestJob
  @queue = :twitter_request

  def self.perform(msg, test_flg)
    Lgdis::ExtOut::Twitter.send_message(msg, test_flg)
  end
end

class Lgdis::ExtOut::Twitter < ActiveRecord::Base
  def self.send_message(msg, test_flg)
    modulename="Twitter"
    o = IfCommon.new
    begin
      if test_flg.blank?
        Twitter.configure do |config|
          config.consumer_key    = API_KEY['twitter']['consumer_key']
          config.consumer_secret = API_KEY['twitter']['consumer_secret']
          config.oauth_token     = API_KEY['twitter']['oauth_token']
          config.oauth_token_secret = API_KEY['twitter']['oauth_token_secret']
        end
        Twitter.update(msg)
      end

      #TODO: アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      Rails.logger.info("#{o.create_log_time(msg, modulename)}")
      status = true
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{o.create_log_time(msg, modulename)}")
      status = false
      # エラー時のメール配信 -> if_common.rbのメソッドを呼び出す
      o.mail_when_delivery_fails
    ensure
      #アーカイブログ出力　  -> if_common.rbのメソッドを呼び出す
      o.leave_log(msg_hash)
      print "\n"
      return status 
    end
  end

end

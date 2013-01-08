class Lgdis::ExtOut::Twitter < ActiveRecord::Base
  def self.send_message(msg, test_flg)
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

      # TODO
      # アーカイブ出力に関して、課題検討中
      # 現在はlogger で対応
      Rails.logger.info("#{create_tw_log_time(msg)}")
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{create_tw_log_time(msg)}")
    ensure
      # TODO
      # 配信管理側に処理完了ステータスを
      # 通知する必要あり
    end
  end

  private

  def self.create_tw_log_time(msg)
    time     = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    time_tw  = "[" + "#{time}" + "]" + "[" + "Twitter" + "]" + " \"" + \
               "#{msg}" + "\""
    return time_tw
  end
end

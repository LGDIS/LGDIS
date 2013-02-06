class Lgdis::ExtOut::Facebook < ActiveRecord::Base
  def self.send_message(msg, test_flg)
    modulename="Facebook"
    o = IfCommon.new
    begin
      if test_flg.blank?
        @graph = Koala::Facebook::API.new(API_KEY['facebook']['app_token'])
        @graph.put_connections(API_KEY['facebook']['user_id'], "feed", :message => msg)
      end

      #TODO: アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      Rails.logger.info("#{o.create_log_time(msg, modulename)}")
      o.leave_log(msg)
      status = true
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{o.create_log_time(msg, modulename)}")
      status = false
    ensure
      #アーカイブログ出力　
      o.leave_log(msg_hash)
      return status 
    end
  end

end

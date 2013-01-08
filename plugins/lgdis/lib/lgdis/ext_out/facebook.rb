class Lgdis::ExtOut::Facebook < ActiveRecord::Base
  def self.send_message(msg, test_flg)
    begin
      if test_flg.blank?
        @graph = Koala::Facebook::API.new(API_KEY['facebook']['app_token'])
        @graph.put_connections(API_KEY['facebook']['user_id'], "feed", :message => msg)
      end

      # TODO
      # アーカイブ出力に関して、課題検討中
      # 現在はlogger で対応
      Rails.logger.info("#{create_fb_log_time(msg)}")
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{create_fb_log_time(msg)}")
    ensure
      # TODO
      # 配信管理側に処理完了ステータスを
      # 通知する必要あり
    end
  end

  private

  def self.create_fb_log_time(msg)
    time     = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    time_fb  = "[" + "#{time}" + "]" + "[" + "Facebook" + "]" + " \"" + \
               "#{msg}" + "\""
    return time_fb
  end
end

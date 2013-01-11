class Lgdis::ExtOut::SOAP_KJcommons  < ActiveRecord::Base
  def self.send_message(msg, test_flg)
    modulename="SOAP_KJcommons"
    o = IfCommon.new
    begin
      if test_flg.blank?
#         @graph = Koala::Facebook::API.new(API_KEY['facebook']['app_token'])
#         @graph.put_connections(API_KEY['facebook']['user_id'], "feed", :message => msg)
#         Twitter.configure do |config|
#           config.consumer_key    = API_KEY['twitter']['consumer_key']
#           config.consumer_secret = API_KEY['twitter']['consumer_secret']
#           config.oauth_token     = API_KEY['twitter']['oauth_token']
#           config.oauth_token_secret = API_KEY['twitter']['oauth_token_secret']
#         end
#         Twitter.update(msg)
      end
      # TODO
      # アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      # ① rake タスクとして、配信要求キューを取得するワーカーを起動する。
      # ② 自治体職員向け SMTP I/F を呼び出す。
      Rails.logger.info("#{o.create_log_time(msg,modulename)}")
      #k-takami アーカイブログ出力例:　
      o.leave_log(msg)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{o.create_log_time(msg,modulename)}")

    ensure
      # TODO
      # 配信管理側に処理完了ステータスを 通知する必要あり
    end
  end
end

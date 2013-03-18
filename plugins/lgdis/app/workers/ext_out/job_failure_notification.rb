# encoding: utf-8
require 'resque/failure/base'

module ExtOut
  class JobFailureNotification < Resque::Failure::Base
    # Lgdis 外部出力 I/F エラー処理
    # ==== Args
    # ==== Return
    # ==== Raise
    def save
      config = DST_LIST["ext_out"]["job_failure_notification"]

      subject = "#{config["title_prefix"]} Resque #{queue}:#{worker}"

      body = "#{config["alert_msg"]}\n" +
             "\n" +
             "#{payload.inspect}\n" +
             "#{exception.message}(#{exception.class})\n" + exception.backtrace.join("\n")

      # 標準出力
      puts("#{subject}\n#{body}")

      # クライアント設定
      client = Lgdis::ExtOut::Smtp.new
      client.test_flag = config["test_flag"]

      client.smtp_mta_fqdn        = config["smtp_server"]["mta_fqdn"]
      client.smtp_port            = config["smtp_server"]["port"]
      client.smtp_domain          = config["smtp_server"]["domain"]
      client.smtp_auth_user_name  = config["smtp_server"]["user_name"]
      client.smtp_auth_password   = config["smtp_server"]["password"]
      client.charset              = config["smtp_server"]["charset"]

      client.from     = config["from"]
      client.to       = config["to"]
      client.subject  = subject
      client.body     = body

      # メール送信
      client.output
    rescue Exception => e
      puts("#{e.message}(#{e.class})\n" + e.backtrace.join("\n"))
    end

  end
end

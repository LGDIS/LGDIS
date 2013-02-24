# encoding: utf-8
module ExtOut
  class SmtpRequestJob < ExtOut::JobBase
    @queue = :extout_smtp_request # Resque キュー名

    # クライアントクラス名
    @@client_class = "Lgdis::ExtOut::Smtp"
    # ログ出力項目
    @@output_log_fields += [:to, :subject]
    # アーカイブ出力項目
    @@output_archive_fields += [
        :smtp_mta_fqdn,
        :smtp_port,
        :smtp_domain,
        :smtp_auth_user_name,
        :smtp_auth_password,
        :from,
        :to,
        :charset,
        :subject,
        :body
      ]

    # Lgdis 外部出力 SMTP I/F 呼出処理
    # ※非同期処理ワーカー処理（Resque向け）
    # ==== Args
    # _delivery_history_id_ :: delivery_history_id
    # _content_ :: 外部出力内容
    # _test_flag_ :: 試験モードフラグ（デフォルトtrue）
    # ==== Return
    # ==== Raise
    def self.perform(delivery_history_id, content, test_flag=true)
      super(delivery_history_id, content, test_flag) do |delivery_history, delivery_place, client|
        # クライアント設定
        client.smtp_mta_fqdn        = delivery_place["smtp_server"]["mta_fqdn"]
        client.smtp_port            = delivery_place["smtp_server"]["port"]
        client.smtp_domain          = delivery_place["smtp_server"]["domain"]
        client.smtp_auth_user_name  = delivery_place["smtp_server"]["user_name"]
        client.smtp_auth_password   = delivery_place["smtp_server"]["password"]
        client.charset              = delivery_place["smtp_server"]["charset"]

        client.from     = delivery_place["from"]
        client.to       = delivery_place["to"]
        client.subject  = content["subject"]
        client.body     = content["body"]

        # メール送信
        client.output
      end
    end

  end
end

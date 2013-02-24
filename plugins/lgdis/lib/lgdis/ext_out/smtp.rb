# encoding: utf-8
module Lgdis
  class ExtOut::Smtp < Lgdis::ExtOut::Base
    # 項目定義
    attr_accessor(
        :smtp_mta_fqdn,
        :smtp_port,
        :smtp_domain,
        :smtp_auth_user_name,
        :smtp_auth_password,
        :from,
        :to,
        :subject,
        :body,
        :charset
      )

    # Lgdis Smtp I/F メール送信処理
    # ==== Args
    # ==== Return
    # ==== Raise
    def output
      client = Lgdis::ExtOut::SmtpClient.setup(
          smtp_settings: {
              address: smtp_mta_fqdn,
              port: smtp_port,
              domain: smtp_domain,
              user_name: smtp_auth_user_name,
              password: smtp_auth_password,
            },
          mail: {
            from: from,
            to: to,
            subject: subject,
            body: body,
            charset: charset
          }
        )
      client.deliver unless test_flag
    end

  end
end

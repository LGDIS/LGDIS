# encoding: utf-8
module Lgdis
  module ExtOut
    class SmtpClient < ActionMailer::Base
      # メールオブジェクト作成
      # ==== Args
      # _args_ :: ActionMailer設定
      # 以下のハッシュを指定のこと
      # * :smtp_settings
      #   * :address
      #   * :port
      #   * :domain
      #   * :user_name
      #   * :password
      # * :mail
      #   * :from
      #   * :to
      #   * :subject
      #   * :body
      #   * :charset
      # ==== Return
      # Mail::Messageオブジェクト
      # ==== Raise
      def setup(args)
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.raise_delivery_errors = true
        smtp_settings = args[:smtp_settings]
        if smtp_settings[:user_name].present? && smtp_settings[:password].present?
          smtp_settings[:authentication] = :login
        end
        ActionMailer::Base.smtp_settings = smtp_settings

        return mail(args[:mail])
      end

    end
  end
end

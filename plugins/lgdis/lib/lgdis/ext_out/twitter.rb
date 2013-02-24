# encoding: utf-8
module Lgdis
  class ExtOut::Twitter < Lgdis::ExtOut::Base
    # 項目定義
    attr_accessor(
        :consumer_key,
        :consumer_secret,
        :oauth_token,
        :oauth_token_secret,
        :message,
      )

    # Lgdis Twitter I/F 投稿処理
    # ==== Args
    # ==== Return
    # ==== Raise
    def output
      client = Twitter::Client.new(
          consumer_key: consumer_key,
          consumer_secret: consumer_secret,
          oauth_token: oauth_token,
          oauth_token_secret: oauth_token_secret,
        )
      client.update(message) unless test_flag
    end

  end
end

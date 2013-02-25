# encoding: utf-8
module Lgdis
  module ExtOut
    class Twitter < Lgdis::ExtOut::Base
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
        # Twitterライブラリの名前空間と、当クラスの名前空間が重複するため、
        # 明示的に外のクラスであることを指定(::始まり)
        client = ::Twitter::Client.new(
            consumer_key: consumer_key,
            consumer_secret: consumer_secret,
            oauth_token: oauth_token,
            oauth_token_secret: oauth_token_secret,
          )
        client.update(message) unless test_flag
      end

    end
  end
end

# encoding: utf-8
module Lgdis
  module ExtOut
    class Commons < Lgdis::ExtOut::Base
      # 項目定義
      attr_accessor(
          :wsdl,
          :endpoint,
          :namespace,
          :username,
          :password,
          :message
        )

      # Lgdis 公共情報コモンズ I/F 送信処理
      # ==== Args
      # ==== Return
      # ==== Raise
      def output
        client = Lgdis::ExtOut::CommonsClient.new( wsdl, endpoint, namespace)
        client.set_auth(username, password)
        client.send(message) unless test_flag
      end

    end
  end
end

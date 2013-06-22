# encoding: utf-8
module Lgdis
  module ExtOut
    class Facebook < Lgdis::ExtOut::Base
      # 項目定義
      attr_accessor(
          :app_token,
          :user_id,
          :page_id,
          :message
        )

      # Lgdis Facebook I/F 投稿処理
      # ==== Args
      # ==== Return
      # ==== Raise
      def output
        client = Koala::Facebook::API.new(app_token)
        client.put_connections(page_id, "feed", :message => message) unless test_flag
      end

    end
  end
end

# encoding: utf-8
module ExtOut
  class FacebookRequestJob < ExtOut::JobBase
    @queue = :extout_facebook_request # Resque キュー名

    # クライアントクラス名
    @@client_class = "Lgdis::ExtOut::Facebook"
    # ログ出力項目
    @@output_log_fields += [:message]
    # アーカイブ出力項目
    @@output_archive_fields += [
        :app_token,
        :user_id,
        :message,
      ]

    # Lgdis 外部出力 Facebook I/F 呼出処理
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
        client.app_token  = API_KEY['facebook']['app_token']
        client.user_id    = API_KEY['facebook']['user_id']
        client.message    = content.to_s

        # 投稿
        client.output
      end
    end

  end
end

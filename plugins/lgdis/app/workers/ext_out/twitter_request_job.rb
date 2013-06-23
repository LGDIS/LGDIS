# encoding: utf-8
module ExtOut
  class TwitterRequestJob < ExtOut::JobBase
    @queue = :extout_twitter_request # Resque キュー名

    # クライアントクラス名
    @@client_class = "Lgdis::ExtOut::Twitter"
    # ログ出力項目
    @@output_log_fields += [:message]
    # アーカイブ出力項目
    @@output_archive_fields += [
        :consumer_key,
        :consumer_secret,
        :oauth_token,
        :oauth_token_secret,
        :message
      ]
    # チケット履歴出力項目
    @@output_issue_journal_fields += [:message]

    # Lgdis 外部出力 Twitter I/F 呼出処理
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
        client.consumer_key       = API_KEY['twitter']['consumer_key']
        client.consumer_secret    = API_KEY['twitter']['consumer_secret']
        client.oauth_token        = API_KEY['twitter']['oauth_token']
        client.oauth_token_secret = API_KEY['twitter']['oauth_token_secret']
        client.message            = content.to_s

        # 投稿
        client.output
      end
    end

  end
end

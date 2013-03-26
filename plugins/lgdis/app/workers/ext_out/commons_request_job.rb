# encoding: utf-8
module ExtOut
  class CommonsRequestJob < ExtOut::JobBase
    @queue = :extout_commons_request # Resque キュー名

    # クライアントクラス名
    @@client_class = "Lgdis::ExtOut::Commons"
    # ログ出力項目
    @@output_log_fields += [:endpoint]
    # アーカイブ出力項目
    @@output_archive_fields += [
        :wsdl,
        :endpoint,
        :namespace,
        :username,
        :password,
        :message
      ]
    # チケット履歴出力項目
    #@@output_issue_journal_fields +=

    # Lgdis 外部出力 公共情報コモンズ I/F 呼出処理
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
        client.wsdl       = DST_LIST["commons_connection"]["wsdl"]
        client.endpoint   = DST_LIST["commons_connection"]["endpoint"]
        client.namespace  = DST_LIST["commons_connection"]["namespace"]
        client.username   = DST_LIST["commons_connection"]["username"]
        client.password   = DST_LIST["commons_connection"]["password"]
        client.message    = content

        # 送信
        client.output
      end
    end

    # チケット履歴向けコンテンツ作成
    # ==== Args
    # _client_ :: クライアントオブジェクト
    # ==== Return
    # コンテンツ文字列
    # ==== Raise
    def self.content_for_issue_journal_of(client)
      # 緊急速報メールの場合のみ存在
      if e = client.message.elements["//pcx_um:UrgentMail/pcx_um:Information/pcx_um:Message"]
        return e.text
      end
      return ""
    end

  end
end

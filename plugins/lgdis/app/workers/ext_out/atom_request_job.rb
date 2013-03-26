# encoding: utf-8
module ExtOut
  class AtomRequestJob < ExtOut::JobBase
    @queue = :extout_atom_request # Resque キュー名

    # クライアントクラス名
    @@client_class = "Lgdis::ExtOut::Atom"
    # ログ出力項目
    @@output_log_fields += [:output_dir, :output_file_name]
    # アーカイブ出力項目
    @@output_archive_fields += [
        :output_dir,
        :output_file_name,
        :data
      ]
    # チケット履歴出力項目
    #@@output_issue_journal_fields +=

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
        client.output_dir  = DST_LIST["atom"]["output_dir"]
        client.output_file_name = "#{Time.now.strftime("%Y%m%d_%H%M%S")}-geoatom.rdf"
        client.data         = content

        # Atom出力
        client.output
      end
    end

  end
end

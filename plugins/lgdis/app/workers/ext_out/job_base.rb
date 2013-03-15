# encoding: utf-8
require 'fileutils'

module ExtOut
  class JobBase
    # logger設定
    cattr_reader(:logger)
    @@logger = Rails.logger.clone
    self.logger.instance_eval do
      def add(severity, message = nil, progname = nil, &block)
        # Note:要因は不明だが、messageではなく、prognameにログ文言が入っている
        puts progname # 標準出力
        super(severity, message, progname, &block)
      end
    end

    # クライアントクラス名（初期値）
    @@client_class = ""
    # ログ出力項目（初期値）
    @@output_log_fields = []
    # アーカイブ出力項目（初期値
    @@output_archive_fields = [:test_flag]

    # Lgdis 外部出力 I/F呼出の共通処理
    # ※非同期処理ワーカー処理（Resque向け）
    # ※各外部出力I/Fの呼出処理は、本関数に実処理をブロックで渡すこと
    # ==== Args
    # _delivery_history_id_ :: delivery_history_id
    # _content_ :: 外部出力内容
    # _test_flag_ :: 試験モードフラグ（デフォルトtrue）
    # _block_ :: 外部出力処理の実処理
    # ==== Return
    # ==== Raise
    def self.perform(delivery_history_id, content, test_flag=true, &block)
      raise "delivery_history_idが未指定です" unless delivery_history_id
      delivery_history = DeliveryHistory.find(delivery_history_id)  # 存在しない場合raise
      delivery_place = (DST_LIST["delivery_place"][delivery_history.delivery_place_id]||{})
      delivery_name = delivery_place["name"]

      start_time = Time.now  # 処理開始日時
      logger.debug("Processing queue of #{delivery_name} #{test_flag ? "TEST " : ""}at #{start_time}")

      begin
        # 外部出力実行
        client = eval("#{@@client_class.to_s}.new")
        client.test_flag = test_flag  # 試験モードフラグ
        yield(delivery_history, delivery_place, client)

        # 文書改版管理処理
        register_edition(content, delivery_history) if DST_LIST['commons_delivery_ids'].include?(delivery_history.delivery_place_id)

        success = true
        return
      ensure
        # ステータス更新
        delivery_history.update_attributes(status: (success ? "done" : "failed")) if delivery_history
        # チケットへの送信履歴書き込み処理
        register_issue_journal(delivery_history, content, success)
        # 配信状況更新処理
        if delivery_history.status == "done"
          delivery_history.issue.custom_values.each do |c|
            if c.custom_field_id == DST_LIST['cf_id_for_show_status']
              c.update_attributes(:value => '1:○')
            end
          end
        end
        # ログ出力
        log_of_output("Completed queue of #{delivery_name} " +
                      "#{test_flag ? "TEST-" : ""}#{success ? "OK" : "NG"} " +
                      "in #{"%.0f" % (1000 * (Time.now.to_f - start_time.to_f))} ms at #{Time.now} " +
                      "#{content_for_log_of(client)}")
        # アーカイブ出力
        archive_of_output("#{Time.now.strftime("%Y%m%d_%H%M%S")}-" +
                          "#{test_flag ? "TEST-" : ""}#{success ? "OK" : "NG"}-" +
                          "#{delivery_name}.log",
                          content_for_archive_of(client) )
      end
    end

    private

    # ログ出力処理
    # ==== Args
    # _content_ :: 出力文字列
    # ==== Return
    # ==== Raise
    def self.log_of_output(content)
      logger.info(content.to_s)
    end

    # ログ向けコンテンツ作成
    # クラス変数のログ出力項目に指定された項目値を、
    # クライアントオブジェクトから『項目名: 項目内容』の体裁で出力します
    # ==== Args
    # _client_ :: クライアントオブジェクト
    # ==== Return
    # コンテンツ文字列
    # ==== Raise
    def self.content_for_log_of(client)
      outputs = []
      (@@output_log_fields || []).each do |field|
        outputs << "#{field}: #{eval("client.#{field}") rescue ""}"
      end
      return "<#{outputs.join(", ")}>"
    end

    # アーカイブ出力処理
    # ==== Args
    # _file_name_ :: ファイル名
    # _content_ :: 出力文字列
    # ==== Return
    # ==== Raise
    def self.archive_of_output(file_name, content)
      archives_dir_path = Pathname(DST_LIST["ext_out"]["archives_dir"])
      FileUtils::mkdir_p(archives_dir_path) unless File.exist?(archives_dir_path) # 出力先ディレクトリを作成
      File.binwrite(archives_dir_path.join(file_name.force_encoding("UTF-8")), content.to_s)
    end

    # アーカイブ向けコンテンツ作成
    # クラス変数のアーカイブ出力項目に指定された項目値を、
    # クライアントオブジェクトから『項目名: 項目内容』の体裁で出力します
    # ==== Args
    # _client_ :: クライアントオブジェクト
    # ==== Return
    # コンテンツ文字列
    # ==== Raise
    def self.content_for_archive_of(client)
      outputs = []
      (@@output_archive_fields || []).each do |field|
        outputs << "#{field}: #{eval("client.#{field}") rescue ""}"
      end
      return outputs.join("\n")
    end

    # 文書改版管理処理｡取り消しされた場合は、版番号を1にリセットする｡
    # ==== Args
    # _delivery_history_ ::: DeliveryHistoryオブジェクト
    # ==== Return
    # ==== Raise
    def self.register_edition(content, delivery_history)
      issue = delivery_history.issue
      project_id = issue.project_id
      tracker_id = issue.tracker_id
      type_update = issue.type_update
      edition_mng = EditionManagement.find_by_project_id_and_tracker_id(project_id, tracker_id)
      xml_body = REXML::Document.new(content)

      # 新規追加処理
      if edition_mng.blank?
        EditionManagement.create(project_id: project_id,
                                 tracker_id: tracker_id,
                                 issue_id:   issue.id,
                                 uuid:       xml_body.elements["//pcx_ib:Head/commons:documentID"].text)
      else
        # [情報の更新種別]が取消の場合、ステータスは1(新規)に戻る、それ以外は2(更新)
        edition_status = type_update == "3" ? 1 : 2
        # 直近の配信で、配信取消されていた場合は、版番号を振りなおす
        # それ以外は版番号をインクリメント
        edition_num = edition_mng.status == 1 ? 1 : edition_mng.edition_num+=1
        edition_mng.update_attributes(status:       edition_status,
                                      edition_num:  edition_num)
      end
    end

    # チケットへの送信履歴書き込み処理
    # ==== Args
    # _delivery_history_ ::: DeliveryHistoryオブジェクト
    # _content_ :: 外部出力内容
    # _success_ ::: 外部出力の実行ステータス
    # ==== Return
    # ==== Raise
    def self.register_issue_journal(delivery_history, content, success)
      issue = delivery_history.issue
      delivery_name = (DST_LIST["delivery_place"][delivery_history.delivery_place_id]||{})["name"].to_s
      delivery_history_id = delivery_history.id.to_s
      delivery_process_date = delivery_history.process_date.strftime("%Y/%m/%d %H:%M:%S")
      notes = ""
      case content
      when String, Hash
        notessuffix = "\n#{content.to_s}"
      when NIL
      end
      notes += "#{delivery_process_date}に処理を行った、 #{delivery_name}配信は、"
      notes += success ? "正常に配信しました。\n" : "異常終了しました。\n"
      notes += notessuffix.to_s
      issue.init_journal(User.current, notes)
      issue.save
    end
  end
end

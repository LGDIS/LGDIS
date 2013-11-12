# -*- coding:utf-8 -*-
# バッチの実行コマンド
# rails runner Batches::EvacuationAdvisoriesList.execute
# ==== options
# 実行環境の指定 :: -e production

require 'cgi'

include ApplicationHelper

class Batches::EvacuationAdvisoriesList

  ATOM = DeliveryHistory::ATOM_ID # RSS配信(Atom)のdelivery_place_id
  TRAINING_MESSAGE = "【災害訓練】"

  def self.execute

    Rails.logger.info(" #{Time.now.to_s} ===== #{self.name} START ===== ")
    time = Time.now # 時間取得
    limit_days = DST_LIST["link_disaster_portal_limit_days"] # 取得範囲発表からXX日以内
    reject_project_ids =DST_LIST["link_disaster_portal_reject_project_ids"] # 対象外プロジェクトID

    auther_name  = DST_LIST["link_disaster_portal_auther_name"]
    auther_email = DST_LIST["link_disaster_portal_auther_email"]

    # 避難勧告・指示のトラッカーID: 1
    create_xml(1)
    Rails.logger.info(" #{Time.now.to_s} ===== #{self.name} END ===== ")

  end

  # GeoRSS 出力用のxmlファイルを返却します。
  # ==== Args
  # tracker_id :: トラッカーID
  # ==== Return　
  # なし xmlファイルを指定パスに出力
  # ==== Raise
  def self.create_xml(tracker_id)

    time = Time.now # 時間取得
    limit_days = DST_LIST["link_disaster_portal_limit_days"] # 取得範囲発表からXX日以内
    reject_project_ids =DST_LIST["link_disaster_portal_reject_project_ids"] # 対象外プロジェクトID

    if DST_LIST["link_disaster_portal_tracker_group"][tracker_id].blank? # 出力項目定義が取得できない場合はスキップ
      Rails.logger.info("#{Time.now.to_s} 設定ファイル(destinationlist.yml)に、ATOM出力項目が定義されていません")
      return
    end

    # 配信除外プロジェクトのチケット取得
    issues_reject_project = Issue.where({:tracker_id => tracker_id}).where("project_id in (?)", reject_project_ids).where("id IN (SELECT issue_id FROM delivery_histories WHERE delivery_place_id = #{ATOM} AND (status = 'done' OR status = 'reserve') AND opened_at <= CURRENT_TIMESTAMP AND ((closed_at IS NOT NULL AND closed_at >= CURRENT_TIMESTAMP) OR (closed_at IS NULL AND opened_at + interval '#{limit_days} days' >= CURRENT_TIMESTAMP)))").order("CASE WHEN closed_at IS NULL THEN opened_at + interval '#{limit_days} days' ELSE closed_at END DESC, opened_at DESC")

    # 通信モードの配信管理更新
    issues_reject_project.each do | issue |
      # 配信管理取得
      dh = issue.delivery_histories.where(:delivery_place_id => ATOM).where(["status = ? OR status = ?", "done", "reserve"]).where("opened_at <= CURRENT_TIMESTAMP").where("(closed_at IS NOT NULL AND closed_at >= CURRENT_TIMESTAMP) OR (closed_at IS NULL AND opened_at + interval '#{limit_days} days' >= CURRENT_TIMESTAMP)").order("CASE WHEN closed_at IS NULL THEN opened_at + interval '#{limit_days} days' ELSE closed_at END DESC, opened_at DESC").first
      # 配信管理更新、チケット履歴出力
      if dh.status == "reserve"
        begin
          dh.status = "done"
          dh.process_date = Time.now
          dh.respond_user_id = 1 if dh.respond_user_id.blank?
          this_register_issue_journal_rss_deliver(dh, issue)
        rescue => e
          Rails.logger.info(e.message)
        end
      end
    end
    
    # 対象トラッカーのチケット取得
    # 配信ステータスが配信予定又は配信完了、かつ、公開開始日時が現在時刻を過ぎていること、
    # かつ、公開終了日時が設定されている場合は、公開終了日時が現在時刻を過ぎていないこと。公開終了日時が設定されていない場合は、公開開始日時に設定ファイルの配信完了期間（日）を足した日付が現在日付を過ぎていないこと。
    # 避難勧告指示は、原則として避難勧告指示タブでその内容を修正し、配信後にチケットの項目を修正することはないため、最後に更新したデータを取得する。
    issues = Issue.where({:tracker_id => tracker_id}).where("project_id not in (?)", reject_project_ids).where("id IN (SELECT issue_id FROM delivery_histories WHERE delivery_place_id = #{ATOM} AND (status = 'done' OR status = 'reserve') AND opened_at <= CURRENT_TIMESTAMP AND ((closed_at IS NOT NULL AND closed_at >= CURRENT_TIMESTAMP) OR (closed_at IS NULL AND opened_at + interval '#{limit_days} days' >= CURRENT_TIMESTAMP)))").order("updated_on DESC").first

    # テンプレートの読み込み
    file = File.new("#{Rails.root}/plugins/lgdis/files/xml/atom_with_georss.xml")
    # Xmlドキュメントの生成
    doc  = REXML::Document.new(file)

    feed = doc.elements["feed"]
    feed.elements["title"].text = DST_LIST["link_disaster_portal_tracker_constants"][tracker_id]["title"]
    feed.elements["updated"].text = time.xmlschema # YYYY-MM-DDThh:mm:ss+9:00 のフォーマットでなくてはならない

    author = feed.elements["author"]
    author.elements["name"].text =  DST_LIST["link_disaster_portal_tracker_constants"][tracker_id]["name"]
    author.elements["email"].text = DST_LIST["link_disaster_portal_tracker_constants"][tracker_id]["email"]

    feed.elements["id"].text = "#{tracker_id}-#{time.strftime("%Y%m%d%H%M%S")}" # TODO 暫定でトラッカーID-YYYYMMDDHH24MISS

    unless issues.blank?
      csvArray = getAttachedCsvArray(issues)

      # 配信管理取得
      dh = issues.delivery_histories.where(:delivery_place_id => ATOM).where(["status = ? OR status = ?", "done", "reserve"]).where("opened_at <= CURRENT_TIMESTAMP").where("(closed_at IS NOT NULL AND closed_at >= CURRENT_TIMESTAMP) OR (closed_at IS NULL AND opened_at + interval '#{limit_days} days' >= CURRENT_TIMESTAMP)").order("CASE WHEN closed_at IS NULL THEN opened_at + interval '#{limit_days} days' ELSE closed_at END DESC, opened_at DESC").first
      # 配信管理更新、チケット履歴出力
      if dh.status == "reserve"
        begin
          if csvArray.nil?
            dh.status = "failed"
          else
            dh.status = "done"
          end
          dh.process_date = Time.now
          dh.respond_user_id = 1 if dh.respond_user_id.blank?
          dh.save!
          this_register_issue_journal_rss_deliver(dh, issues)
        rescue => e
          Rails.logger.info(e.message)
        end
      end

      return if csvArray.nil?

      header = csvArray.take(1)[0]

      #ソート処理 ここから
      csvArray = csvArray.sort{|p,q|p[2]<=>q[2]}

      sort_key1 = ["警戒区域" , "避難指示" , "避難勧告" , "避難準備" ,  "警戒情報" ]

      tmpdata = Hash.new
      csvArray.each do |row|
        if !tmpdata.has_key?(row[2])
          tmpdata[row[2]] = []
        end
        tmpdata[row[2]]<< row
      end

      outtemp = Hash.new

      sort_key1.each do |sort_key|
        outtemp[sort_key] = tmpdata[sort_key]
      end

      tmpdata = outtemp

      tmp = Array.new
      output = Array.new
      output_other = Array.new

      #上記のコードですでに地域ごとにソートされているので
      #ステータスのソートの順番を指定
      sort_array = ["発令","解除",""]

      tmpdata.each do |key,value|

        tmp = tmpdata[key]
        sort_array.each do |sort_key|

          if tmp.nil?
          else
            tmp.each do |value2|
              if value2[7].to_s == sort_key.to_s then
                output << value2
              end
            end
          end
        end
      end

      #ソート処理 ここまで
      csvArray = output

      counter = 0

      csvArray.each do |row|
        # XML main entry
        new_entry = REXML::Element.new("entry")

        training_header = DST_LIST["training_prj"][issues.project_id] ? TRAINING_MESSAGE : ""

        new_entry.add_element("title").add_text(training_header + "#{row[0]}")
        new_entry.add_element("id").add_text("#{issues.id}-#{dh.published_at.strftime("%Y%m%d%H%M%S")}-#{format('%04d', counter)}") # TODO 暫定でチケットID-YYYYMMDDHH24MISS
        new_entry.add_element("published").add_text(dh.published_at.xmlschema)
        new_entry.add_element("updated").add_text(dh.published_at.xmlschema)
        #content 追加開始
        content = ""

        #0 あり　対象地区
        #2 あり　発令区分
        #3 あり  発令日時
        #4 あり　解除日時
        #5 あり　対象世帯人数
        #6 あり　対象人数
        #7 あり　発令・解除区分

        row_order = [0,2,3,4,5,6]
        row_order.each do |order|
          work_content = row[order]
          # 発令区分は、発令・解除の区分も加える。
          work_content = work_content + " " + row[7] if order == 2
          content += "&lt;br /&gt;&lt;br /&gt;" unless content.blank?
          content += header[order] + ':' + work_content
        end

        content = TRAINING_MESSAGE + "&lt;br /&gt;" + content if DST_LIST["training_prj"][issues.project_id]

        ele_content = new_entry.add_element("content")
        ele_content.add_attribute("type","html")
        ele_content.add_text(content)

        #避難勧告ではgercode は出力しない
        feed.add_text(new_entry)

        counter = counter + 1
      end
    end
    # fileに書き出し
    output_dir_path  = Pathname(DST_LIST["atom"]["output_dir"])

    output_file_name = "tracker_#{tracker_id}.rss"

    FileUtils::mkdir_p(output_dir_path) unless File.exist?(output_dir_path) # 出力先ディレクトリを作成

    File.binwrite(output_dir_path.join(output_file_name.force_encoding("UTF-8")), CGI::unescapeHTML(doc.to_s)) # &amp;→& の為unescapeする

  end

  def self.getAttachedCsvArray(issue)

    require "csv"

    @attachements = issue.attachments

    disk_filename = ""
    @attachements.each do | attachment |
      disk_filename = attachment.disk_filename
    end

    disk_fullpath_filename = Rails.root.to_s + "/files/" + disk_filename

    #csv ファイルを読み込む 文字コード変換を行う
    reader = CSV.open(disk_fullpath_filename, "r" ,encoding: "SJIS:UTF-8")

    return reader

  end

  def self.this_register_issue_journal_rss_deliver(delivery_history, issue)
    notes = []
    delivery_name = (DST_LIST["delivery_place"][delivery_history.delivery_place_id]||{})["name"].to_s
    delivery_process_date = delivery_history.process_date.strftime("%Y/%m/%d %H:%M:%S")
    if delivery_history.status == "done"
      notes << "#{delivery_process_date}に、 #{delivery_name}配信を開始しました。"
    else
      notes << "#{delivery_name}配信に失敗しました。避難勧告指示タブからチケット登録がなされていないか、チケットに添付されたCSVファイルが削除されています。"
    end
    notes << issue.add_url_and_training(delivery_history.summary, ATOM, issue.project_id)

    @current_journal ||= Journal.new(:journalized => issue, :user => delivery_history.respond_user, :notes => notes.join("\n"))
    @current_journal.notify = false

    @current_journal.save!
  end

end

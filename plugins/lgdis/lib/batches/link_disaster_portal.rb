# -*- coding:utf-8 -*-
# バッチの実行コマンド
# rails runner Batches::LinkDisasterPortal.execute
# ==== options
# 実行環境の指定 :: -e production

require 'cgi'

include ApplicationHelper

ATOM = 9 # RSS配信(Atom)のdelivery_place_id
class Batches::LinkDisasterPortal
  def self.execute

    Rails.logger.info(" #{Time.now.to_s} ===== #{self.name} START ===== ")
    time = Time.now # 時間取得
    limit_days = DST_LIST["link_disaster_portal_limit_days"] # 取得範囲発表からXX日以内
    max_num    = DST_LIST["link_disaster_portal_max_num"]    # １ファイルあたりの最大チケット件数
    reject_project_ids =DST_LIST["link_disaster_portal_reject_project_ids"] # 対象外プロジェクトID

    auther_name  = DST_LIST["link_disaster_portal_auther_name"]
    auther_email = DST_LIST["link_disaster_portal_auther_email"]

    # 連携対象のトラッカーID
    tracker_ids = DST_LIST["link_disaster_portal_tracker_ids"]

    tracker_ids.each do | tracker_id |
       create_xml(tracker_id)
    end

  end

  # map表示向けの場所（location）ハッシュ配列を返却します
  # ==== Args
  # ==== Return
  # map表示向けのハッシュ配列 ※空の場合は[]
  # * "location" :: 場所文字列
  # * "remarks" :: 備考
  # ==== Raise
  def self.locations_for_map(issue)
    locations = []
    issue.issue_geographies.each do |ig|
      next if ig.location.blank?
      locations << ig.location_for_map
    end
    return locations
  end

  # map表示向けの経緯度（point）ハッシュ配列を返却します
  # ==== Args
  # _to_datum_ :: 必要な測地系 ※未指定の場合は世界測地系
  # ==== Return
  # map表示向けのハッシュ配列 ※空の場合は[]
  # * "points"  :: 座標
  # * "remarks" :: 備考
  # ==== Raise
  def self.points_for_map(issue, to_datum = IssueGeography::DATUM_JGD)
    points = []
    issue.issue_geographies.each do |ig|
      next if ig.point.blank?
      points << ig.point_for_map(to_datum)
    end
    return points
  end

  # map表示向けの線（line）ハッシュ配列を返却します
  # ==== Args
  # _to_datum_ :: 必要な測地系 ※未指定の場合は世界測地系
  # ==== Return
  # map表示向けのハッシュ配列 ※空の場合は[]
  # * "points"  :: 座標
  # * "remarks" :: 備考
  # ==== Raise
  def self.lines_for_map(issue, to_datum = IssueGeography::DATUM_JGD)
    lines = []
    issue.issue_geographies.each do |ig|
      next if ig.line.blank?
      lines << ig.line_for_map(to_datum)
    end
    return lines
  end

  # map表示向けの多角形（polygon）ハッシュ配列を返却します
  # ==== Args
  # _to_datum_ :: 必要な測地系 ※未指定の場合は世界測地系
  # ==== Return
  # map表示向けのハッシュ配列 ※空の場合は[]
  # * "points"  :: 座標
  # * "remarks" :: 備考
  # ==== Raise
  def self.polygons_for_map(issue, to_datum = IssueGeography::DATUM_JGD)
    polygons = []
    issue.issue_geographies.each do |ig|
      next if ig.polygon.blank?
      polygons << ig.polygon_for_map(to_datum)
    end
    return polygons
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
    max_num    = DST_LIST["link_disaster_portal_max_num"]    # １ファイルあたりの最大チケット件数
    reject_project_ids = DST_LIST["link_disaster_portal_reject_project_ids"] # 対象外プロジェクトID

    if DST_LIST["link_disaster_portal_tracker_group"][tracker_id].blank? # 出力項目定義が取得できない場合はスキップ
      return
    end

    # 対象トラッカーのチケット取得
    issues = Issue.where({:tracker_id => tracker_id}).where("project_id not in (?)", reject_project_ids).order("updated_on DESC")

    # 出力対象の条件にあてはまらないチケットを削除
    issues.delete_if do |issue|

      # 配信管理を取得 配信先がATOM、公開開始日時が現在日時より過去XX日以内(XXは設定ファイルに記述)の中で最新のもの
      dh = issue.delivery_histories.where(:delivery_place_id => ATOM).order("updated_at DESC").find(:all, :conditions => ["opened_at > CURRENT_TIMESTAMP - interval '#{limit_days} days'"]).first
      next true if dh.blank? # 配信管理が無かった場合、配信対象なし

      # 以下の条件以外の場合は配信しない
      # 配信ステータスが完了または予定、かつ公開開始に至っていて、かつ公開終了日時が空白または公開終了日時に至っていない
      unless (dh.status == "done" || dh.status == "reserve") && (time > dh.opened_at && (dh.closed_at.blank? || time < dh.closed_at))
        next true
      end
      false
    end

    # 最大件数以内に絞り込み
    issues = issues[0..max_num-1]
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

    # チケットごとのループ
    issues.each do | issue |
      # 配信管理取得
      dh = issue.delivery_histories.where(:delivery_place_id => ATOM).order("updated_at DESC").find(:all, :conditions => ["opened_at > CURRENT_TIMESTAMP - interval '#{limit_days} days'"]).first

      # 配信管理更新、チケット履歴出力
      if dh.status == "reserve"
        begin
          dh.status = "done"
          dh.process_date = Time.now
          dh.respond_user_id = 1
          dh.save!
          this_register_issue_journal_rss_deliver(dh,issue)
        rescue =>e
          Rails.logger.info(e.message)
        end
      end

      # XML main entry
      new_entry = REXML::Element.new("entry")
      training_header = DST_LIST["training_prj"][issue.project_id] ? "【災害訓練】" : ""
      new_entry.add_element("title").add_text(training_header + "#{dh.mail_subject}")

      new_entry.add_element("id").add_text("#{issue.id}-#{time.strftime("%Y%m%d%H%M%S")}") # TODO 暫定でチケットID-YYYYMMDDHH24MISS
      new_entry.add_element("published").add_text(dh.opened_at.xmlschema)
      new_entry.add_element("updated").add_text(dh.opened_at.xmlschema)

      content = ""
      DST_LIST["link_disaster_portal_tracker_group"][tracker_id].each do | label_value |

      begin
        tmp_label_value = eval(label_value["value"])
      rescue
        tmp_label_value = ""
      end

      #xml では &nbsp; は認識されないので文字コードを直接入力（＆#x00A0;）
      content += '&lt;p&gt;' + label_value["label"] + ':' + tmp_label_value + '&lt;/p&gt;&lt;br&#x00A0;/&gt;'

    end

    ele_content = new_entry.add_element("content")
    ele_content.add_attribute("type","html")
    ele_content.add_text(content)

    # XML geo
    points_flag = false

    points_for_map(issue).each do |point|
      new_entry.add_element("georss:point").text = point["points"].join(" ")
      points_flag = true
    end

    #データに geo がない場合には、事象の発生場所のgeo 情報
    begin
      unless points_flag
        new_entry.add_element("georss:point").text = ""
      end
    rescue
      new_entry.add_element("georss:point").text = ""
    end

    feed.add_text(new_entry)

    end

    # fileに書き出し
    output_dir_path  = Pathname(DST_LIST["atom"]["output_dir"])
    output_file_name = "tracker_#{tracker_id}.rss"
    FileUtils::mkdir_p(output_dir_path) unless File.exist?(output_dir_path) # 出力先ディレクトリを作成
    File.binwrite(output_dir_path.join(output_file_name.force_encoding("UTF-8")), CGI::unescapeHTML(doc.to_s)) # &amp;→& の為unescapeする
  end

  def self.this_register_issue_journal_rss_deliver(delivery_history,issue)
    notes = []
    delivery_name = (DST_LIST["delivery_place"][delivery_history.delivery_place_id]||{})["name"].to_s
    delivery_process_date = delivery_history.process_date.strftime("%Y/%m/%d %H:%M:%S")
    notes << "#{delivery_process_date}に、 #{delivery_name}配信を開始しました。"
    notes << delivery_history.summary

    @current_journal ||= Journal.new(:journalized => issue, :user => delivery_history.respond_user, :notes => notes.join("\n"))
    @current_journal.notify = false

    @current_journal.save!
  end

end

# -*- coding:utf-8 -*-
# バッチの実行コマンド
# rails runner Batches::LinkDisasterPortal.execute
# ==== options
# 実行環境の指定 :: -e production

require 'cgi'
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
      next if DST_LIST["link_disaster_portal_tracker_group"][tracker_id].blank? # 出力項目定義が取得できない場合はスキップ
      
      # 対象トラッカーのチケット取得
      issues = Issue.where({:tracker_id => tracker_id}).where("project_id not in (?)", reject_project_ids).order("updated_on DESC") # TODO 対象外プロジェクトの条件を追加する
      
      # 出力対象の条件にあてはまらないチケットを削除
      issues.delete_if do |issue|
        
        # 配信管理を取得 配信先がATOM、公開開始日時が現在日時より過去XX日以内(XXは設定ファイルに記述)の中で最新のもの
        dh = issue.delivery_histories.where(:delivery_place_id => ATOM).order("updated_at DESC").find(:all, :conditions => ["opened_at > CURRENT_TIMESTAMP - interval '#{limit_days} days'"]).first
        next true if dh.blank? # 配信管理が無かった場合、配信対象なし
        
        #以下の２つの条件以外の場合
        unless ( 
                 (dh.status == "done"    && (dh.closed_at.blank? ? true : time < dh.closed_at)) || # ステータス配信完了、かつ公開終了日時に至っていない
                 (dh.status == "runtime" && time > dh.opened_at)                                   # ステータス配信予定、かつ公開開始日時に至っている
                 # TODO ↑"runtime"は配信中だが、配信予定のステータスが追加される予定
               )
          next true
        end
        false
      end
      
      next if issues.blank? # 出力対象のチケットが存在しない場合はスキップ
      
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
        if dh.status == "runtime" # TODO 今後「配信中(runtime)」が「配信予定」になるので要修正
          dh.status = "done"
          dh.process_date = Time.now
          dh.save!
          issue.register_issue_journal_rss_deliver(dh)
        end
        
        # XML main entry
        new_entry = REXML::Element.new("entry")
        training_header = DST_LIST["training_prj"][issue.project_id] ? "【訓練】" : ""
        new_entry.add_element("title").add_text(training_header + "#{dh.mail_subject}")
        new_entry.add_element("id").add_text("#{issue.id}-#{time.strftime("%Y%m%d%H%M%S")}") # TODO 暫定でチケットID-YYYYMMDDHH24MISS
        new_entry.add_element("published").add_text(dh.opened_at.xmlschema)
        new_entry.add_element("updated").add_text(dh.opened_at.xmlschema)
        
        content = ""
        DST_LIST["link_disaster_portal_tracker_group"][tracker_id].each do | label_value |
          # content 内容作成
          #content += '<p>' + label_value["label"] + ':' + eval(label_value["value"]) + '</p><br />\n' 半角スペースは&nbsp;に変換されないので直接文字参照で記述し「&」をデコードする、 
          content += '&lt;p&gt;' + label_value["label"] + ':' + eval(label_value["value"]) + '&lt;/p&gt;&lt;br&nbsp;/&gt;\n'
        end
        
        ele_content = new_entry.add_element("content")
        ele_content.add_attribute("type","html")
        ele_content.add_text(content)
        
        # XML geo
        points_for_map(issue).each do |point|
          new_entry.add_element("georss:point").text = point["points"].join(" ")
        end

        lines_for_map(issue).each do |line|
          new_entry.add_element("georss:line").text = line["points"].flatten.join(" ")
        end

        polygons_for_map(issue).each do |polygon|
          new_entry.add_element("georss:polygon").text = polygon["points"].flatten.join(" ")
        end

        locations_for_map(issue).each do |location|
          new_entry.add_element("georss:featureTypeTag").text = location["location"]
        end
        
        feed.add_text(new_entry)
        
      end
      
      # fileに書き出し
      output_dir_path  = Pathname(DST_LIST["atom"]["output_dir"])
      output_file_name = "Tracker#{tracker_id}-#{Time.now.strftime("%Y%m%d_%H%M%S")}-geoatom.xml" # TODO: ファイル名未決定
      
      FileUtils::mkdir_p(output_dir_path) unless File.exist?(output_dir_path) # 出力先ディレクトリを作成
      File.binwrite(output_dir_path.join(output_file_name.force_encoding("UTF-8")), CGI::unescapeHTML(doc.to_s)) # &amp;→& の為unescapeする
      
    end
    
    Rails.logger.info(" #{Time.now.to_s} ===== #{self.name}  END  ===== ")
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

end

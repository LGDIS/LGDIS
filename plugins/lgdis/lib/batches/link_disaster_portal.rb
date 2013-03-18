# -*- coding:utf-8 -*-
# バッチの実行コマンド
# rails runner Batches::LinkDisasterPortal.execute
# ==== options
# 実行環境の指定 :: -e production

require 'cgi'

class Batches::LinkDisasterPortal < ActiveRecord::Base
  def self.execute
    Rails.logger.info(" #{Time.now.to_s} ===== #{self.name} START ===== ")
    
    # プロジェクトIDが未設定、または設定してあるプロジェクトIDのデータが存在しない場合は終了
    if DST_LIST["link_disaster_portal_project_id"].blank? || Project.where({:id => DST_LIST["link_disaster_portal_project_id"]}).blank?
      Rails.logger.info(" #{Time.now.to_s} ===== #{self.name} PROJECT ID is not setting. ===== ")
      Rails.logger.info(" #{Time.now.to_s} ===== #{self.name}  END  ===== ")
      return
    end
    pj = Project.where({:id => DST_LIST["link_disaster_portal_project_id"]}).first
    
    auther_name  = DST_LIST["link_disaster_portal_auther_name"]
    auther_email = DST_LIST["link_disaster_portal_auther_email"]
    
    # 連携対象のトラッカーID
    tracker_ids = DST_LIST["link_disaster_portal_tracker_ids"]
    
    tracker_ids.each do | tracker_id |
      next unless pj.tracker_ids.include?( tracker_id ) # プロジェクトにひも付かないトラッカーはスキップ
      next if DST_LIST["link_disaster_portal_tracker_group"][tracker_id].blank? # 出力項目定義が取得できない場合はスキップ
      
      # 対象トラッカーのチケット取得
      issues = Issue.where({:tracker_id => tracker_id})
      
      next if issues.blank? # 出力対象のチケットが存在しない場合はスキップ
      
      # テンプレートの読み込み
      file = File.new("#{Rails.root}/plugins/lgdis/files/xml/atom_with_georss.xml")
      # Xmlドキュメントの生成
      doc  = REXML::Document.new(file)
      
      feed = doc.elements["feed"]
      feed.elements["title"].text = pj.name
      
      #CGI off-line mode回避用ダミーコード:最後にコントロールDを入れる作業を回避
      ARGV.replace(%w(abc=001 def=002))
      cgi = CGI.new
      feed.elements["link"].attributes["href"] += "#{cgi.server_name}/r/feed/"
      
      time = Time.now
      feed.elements["updated"].text = time.xmlschema
      
      author = feed.elements["author"]
      author.elements["name"].text = auther_name
      author.elements["email"].text = auther_email
      
      feed.elements["id"].text = "urn:uuid:" + UUIDTools::UUID.random_create.to_s # TODO 後述のUUIDと同じものを使うかどうか確認
      
      
      # チケットごとのループ
      issues.each do | issue |
        # XML main entry
        new_entry = REXML::Element.new("entry")
        
        new_entry.add_element("title").add_text("#{issue.tracker.name} ##{issue.id}: #{issue.subject}")
        # TODO サンプルにはここに<link>タグがあるが、出力内容が未定。
        new_entry.add_element("id").add_text("urn:uuid:" + UUIDTools::UUID.random_create.to_s) # TODO 前述のUUIDと同じものを使うかどうか確認
        new_entry.add_element("updated").add_text(time.xmlschema)
        new_entry.add_element("summary").add_text(issue.description.to_s[0,140])
        
        content = "<hr><ul>"
        DST_LIST["link_disaster_portal_tracker_group"][tracker_id].each do | label_value |
          # content 内容作成
          content += '<li type= "circle "><strong>' + label_value["label"] + ':</strong></li>'
          content += eval(label_value["value"]) + '<br>'
        end
        content += "</ul>"
        
        ele_contents = new_entry.add_element("content")
        ele_contents.add_attribute("type","html")
        ele_contents.add_text(content)
        
        # XML geo
        cnt = 0
        points_for_map(issue).each do |point|
          cnt += 1
          REXML::Comment.new("-------- 本件についての地理情報 No." + cnt.to_s + " --------", new_entry)
          new_entry.add_element("georss:point").text = point["points"].join(" ")
          new_entry.add_element("georss:relationshipTag").text = "iconfile=#{rand(16)}-dot.png" # TODO この情報は必要か確認
        end

        lines_for_map(issue).each do |line|
          cnt += 1
          REXML::Comment.new("-------- 本件についての地理情報 No." + cnt.to_s + " --------", new_entry)
          new_entry.add_element("georss:line").text = line["points"].flatten.join(" ")
          new_entry.add_element("georss:relationshipTag").text = "iconfile=#{rand(16)}-dot.png" # TODO この情報は必要か確認
        end

        polygons_for_map(issue).each do |polygon|
          cnt += 1
          REXML::Comment.new("-------- 本件についての地理情報 No." + cnt.to_s + " --------", new_entry)
          new_entry.add_element("georss:polygon").text = polygon["points"].flatten.join(" ")
          new_entry.add_element("georss:relationshipTag").text = "iconfile=#{rand(16)}-dot.png" # TODO この情報は必要か確認
        end

        locations_for_map(issue).each do |location|
          cnt += 1
          REXML::Comment.new("-------- 本件についての地理情報 No." + cnt.to_s + " --------", new_entry)
          new_entry.add_element("georss:featureTypeTag").text = location["location"]
          new_entry.add_element("georss:relationshipTag").text = "iconfile=#{rand(16)}-dot.png" # TODO この情報は必要か確認
        end
        
        feed.add_text(new_entry)
        
      end
      
      # fileに書き出し
      output_dir_path  = Pathname(DST_LIST["atom"]["output_dir"])
      output_file_name = "Tracker#{tracker_id}-#{Time.now.strftime("%Y%m%d_%H%M%S")}-geoatom.xml" # TODO: ファイル名未決定
      
      FileUtils::mkdir_p(output_dir_path) unless File.exist?(output_dir_path) # 出力先ディレクトリを作成
      File.binwrite(output_dir_path.join(output_file_name.force_encoding("UTF-8")), CGI::unescapeHTML(doc.to_s))
      
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

# -*- coding:utf-8 -*-
# バッチの実行コマンド
# rails runner Batches::ShelterList.execute
# ==== options
# 実行環境の指定 :: -e production

require 'cgi'

include ApplicationHelper

ATOM = 9 # RSS配信(Atom)のdelivery_place_id
class Batches::ShelterList
  def self.execute

    Rails.logger.info(" #{Time.now.to_s} ===== #{self.name} START ===== ")
    time = Time.now # 時間取得
    limit_days = DST_LIST["link_disaster_portal_limit_days"] # 取得範囲発表からXX日以内
    reject_project_ids = DST_LIST["link_disaster_portal_reject_project_ids"] # 対象外プロジェクトID

    auther_name  = DST_LIST["link_disaster_portal_auther_name"]
    auther_email = DST_LIST["link_disaster_portal_auther_email"]

    # 連携対象のトラッカーID
    tracker_ids = DST_LIST["link_disaster_portal_tracker_ids"]

    create_xml(2)

  end

  # GeoRSS 出力用のxmlファイルを返却します。
  # ==== Args
  # tracker_id :: トラッカーID
  # ==== Return　
  # なし xmlファイルを指定パスに出力
  # ==== Raise
  def self.create_xml(tracker_id)

    #仕様変更により作り変えgeocode が入力されているCSVから
    #読み込むように修正
    geoArray = getShelterGeoCsvArray()

    time = Time.now # 時間取得
    limit_days = DST_LIST["link_disaster_portal_limit_days"] # 取得範囲発表からXX日以内
    reject_project_ids = DST_LIST["link_disaster_portal_reject_project_ids"] # 対象外プロジェクトID

    if DST_LIST["link_disaster_portal_tracker_group"][tracker_id].blank? # 出力項目定義が取得できない場合はスキップ
      return
    end

    # 対象トラッカーのチケット取得
    issues = Issue.where({:tracker_id => tracker_id}).order("updated_on DESC")

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
      #CSV データの取得
      csvArray = getAttachedCsvArray(issues[0])

      header = csvArray.take(1)[0]

      #ソート処理 ここから
      csvArray = csvArray.sort{|p,q|p[2]<=>q[2]}

      tmpdata = Hash.new
      csvArray.each do |row|
        if !tmpdata.has_key?(row[2])
          tmpdata[row[2]] = []
        end
        tmpdata[row[2]]<< row
      end

      tmp = Array.new
      output = Array.new

      #上記のコードですでに地域ごとにソートされているので
      #ステータスのソートの順番を指定
      sort_array = ["常設","開設","未開設","閉鎖","不明"]

      tmpdata.each do |key,value|
        tmp = tmpdata[key]
        sort_array.each do |sort_key|
          tmp.each do |value2|
            if value2[10].to_s == sort_key.to_s then
              output << value2
            end
          end
        end
      end

      csvArray = output
      #ソート処理 ここまで
      csvArray.each do |row|
        # XML main entry
        new_entry = REXML::Element.new("entry")

        # 避難所名
        training_header = DST_LIST["training_prj"][issues[0].project_id] ? "【災害訓練】" : ""

        new_entry.add_element("title").add_text(training_header + "#{row[0]}")

        new_entry.add_element("id").add_text("#{issues[0].id}-#{time.strftime("%Y%m%d%H%M%S")}") # TODO 暫定でチケットID-YYYYMMDDHH24MISS

        # content 追加開始
        content = ""

        # 0 あり 避難所名
        # 8 あり 避難所種別
        # 2 あり 地区名
        # 4 あり TEL
        # 10 あり 開設状況
        # 11 あり 開設日時
        # 12 あり 閉鎖日時
        # 13 あり 最大収容人数
        # 15 あり 収容人数

        row_order = [0,8,2,4,10,11,12,13,15,16,17,18]
        row_order.each do |order|
          #xml では &nbsp; は認識されないので文字コードを直接入力（＆#x00A0;）
          content += '&lt;p&gt;' + header[order] + ':' + row[order] + '&lt;/p&gt;&lt;br&#x00A0;/&gt;'
        end

        ele_content = new_entry.add_element("content")
        ele_content.add_attribute("type","html")
        ele_content.add_text(content)

        if geoArray[row[0]].present? then
          new_entry.add_element("georss:point").text = geoArray[row[0]]['lat'].to_s + ' ' + geoArray[row[0]]['lng'].to_s
        else
          new_entry.add_element("georss:point").text = ""
        end

        feed.add_text(new_entry)
        #entry の追加終了
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

  def self.getShelterGeoCsvArray()

    # fileに書き出し
    csv_dir_path = "./tmp"
    csv_dir_path = csv_dir_path.gsub("./","")
    csv_file_name = "/shelters_geographies.csv"
    disk_fullpath_filename = Rails.root.to_s + "/" + csv_dir_path.to_s + csv_file_name

    #csv ファイルを読み込む 文字コード変換を行う
    reader = CSV.open(disk_fullpath_filename, "r" ,encoding: "SJIS:UTF-8")
    temp = Hash.new

      reader.each do |row|
        if !temp.has_key?(row[0])
          temp[row[0]] = Hash.new
        end
        temp[row[0]]["lat"] = row[1]
        temp[row[0]]["lng"] = row[2]
      end

    return temp

  end
end

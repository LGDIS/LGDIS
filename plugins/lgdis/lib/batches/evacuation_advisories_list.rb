# -*- coding:utf-8 -*-
# バッチの実行コマンド
# rails runner Batches::EvacuationAdvisoriesList.execute
# ==== options
# 実行環境の指定 :: -e production

require 'cgi'

include ApplicationHelper

ATOM = 9 # RSS配信(Atom)のdelivery_place_id
class Batches::EvacuationAdvisoriesList
  def self.execute

    #begin

    Rails.logger.info(" #{Time.now.to_s} ===== #{self.name} START ===== ")
    time = Time.now # 時間取得
    limit_days = DST_LIST["link_disaster_portal_limit_days"] # 取得範囲発表からXX日以内
    reject_project_ids =DST_LIST["link_disaster_portal_reject_project_ids"] # 対象外プロジェクトID

    auther_name  = DST_LIST["link_disaster_portal_auther_name"]
    auther_email = DST_LIST["link_disaster_portal_auther_email"]

    # 連携対象のトラッカーID
    tracker_ids = DST_LIST["link_disaster_portal_tracker_ids"]

#    tracker_ids.each do | tracker_id |
       create_xml(1)
#    end

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
      return
    end

    # 対象トラッカーのチケット取得

#    issues = Issue.where({:tracker_id => tracker_id}).order("updated_on DESC")
    issue = Issue.where({:tracker_id => tracker_id}).order("updated_on DESC").first


    if issue.blank? # 出力対象のチケットが存在しない場合は終了
      return
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

    # チケットごとのループ
#    issues.each do | issue |


      csvArray = getAttachedCsvArray(issue)

      header = csvArray.take(1)[0]



      #ソート処理 ここから
      csvArray = csvArray.sort{|p,q|p[2]<=>q[2]}


      sort_key1 = ["警戒区域" , "避難指示" , "避難勧告" , "避難準備情報" ,  "警戒情報" ]


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
#      sort_array = ["発令","解除" ,""]
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


csvArray.each do |row|
      # XML main entry
      new_entry = REXML::Element.new("entry")

      #避難所名


      training_header = DST_LIST["training_prj"][issue.project_id] ? "【災害訓練】" : ""

      new_entry.add_element("title").add_text(training_header + "#{row[0]}")
      new_entry.add_element("id").add_text("#{issue.id}-#{time.strftime("%Y%m%d%H%M%S")}") # TODO 暫定でチケットID-YYYYMMDDHH24MISS


#content 追加開始
      content = ""




# 0 あり　避難所名
#8 あり　避難所種別
#2 あり　地区名
#4 あり　TEL
#10 あり　開設状況
#11 あり　開設日時
#12 あり　閉鎖日時
#13 あり　最大収容人数
#15 あり　収容人数



row_order = [0,2,3,4,5,6,7]
      row_order.each do |order|

      #xml では &nbsp; は認識されないので文字コードを直接入力（＆#x00A0;）
        content += '&lt;p&gt;' + header[order] + ':' + row[order] + '&lt;/p&gt;&lt;br&#x00A0;/&gt;'
      end


      ele_content = new_entry.add_element("content")
      ele_content.add_attribute("type","html")
      ele_content.add_text(content)

#避難勧告ではgercode は出力しない

      feed.add_text(new_entry)

#entry の追加終了
end

#    end

    # fileに書き出し
    output_dir_path  = Pathname(DST_LIST["atom"]["output_dir"])

    output_file_name =  "#{tracker_id}_track.rss"

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

end

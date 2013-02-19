# -*- encoding: utf-8 -*-
#Simple-geoATOM ファイル生成出力プログラム本体
#つかいかた:
#  スクリプトとしてつかうばあいは ruby feeder.rb
#  Railsコンソールから呼ぶ場合は､RedmineのIssueオブジェクトを引数にして以下の様に呼び出す;
#    例: SetupXML.arrange_and_put(Issue.all[1])
#  ref:/#{Rails.root}/app/views/journals/index.builder

#Simple-geoATOM テンプレートファイル "*.tmpl"のメタタグ記法
# #{ }でそのまま出力
# %{ }でHTMLエスケープして出力
# !{ }内はRubyのコードとして実行する
# データはインスタンス変数としてセットされるので@で使える

#JMA-XML tags examples:  ref:vimgrep /\(ol.gon\|ine\|oint\)/ **/*xml
  #line    tag =  # <westBoundLongitude>140.250000</westBoundLongitude> 
                  # <eastBoundLongitude>141.750000</eastBoundLongitude> 
                  # <southBoundLatitude>37.750000</southBoundLatitude>
                  # <northBoundLatitude>39.083333</northBoundLatitude>
  #point   tag = <gml:Point gml:id="PT_02367"><gml:pos>38.75053389 141.26430417</gml:pos></gml:Point>
          #poligon tag = <gml:posList>

require "cgi"

class Template
  # テンプレートから作成したViewを取得しインスタンス生成
  # ==== Args
  # _tmpl_path_ :: XMLテンプレートのファイルシステム上のフルパス
  # ==== Return
  # __ :: Viewのインスタンス
  # ==== Raise
  def self.get(tmpl_path, http_headers = "text/html")
    view_path = tmpl_path + ".view.rb"    # Viewのファイルパス
    # Viewのクラス名
    view_name = "View_" + tmpl_path.sub(/^.+\//,"").gsub(/[-.]/, "_")    
    # Viewクラスがまだ無いか、テンプレートより古い場合はViewクラスを作成する
    if !FileTest.exist?(view_path) || File::stat(tmpl_path).mtime > File::stat(view_path).mtime
        self.create_view(tmpl_path, view_path, view_name)
    end
    # Viewクラスを読み込む
    load view_path    
    # HTTPヘッダ出力
    print CGI.new.header(http_headers)    
    # Viewのインスタンスを返す
    return eval(view_name + ".new")    
  end

  # Viewクラスを定義するファイルを生成する
  # ==== Args
  # _tmpl_path_ :: XMLテンプレートのファイルシステム上のフルパス
  # _view_path_ :: XML Viewのファイル名｡フルパス指定で｡
  # ==== Return
  # ==== Raise
  def self.create_view(tmpl_path, view_path, view_name)
    # テンプレート内で使っているインスタンス変数をここに溜める
    vars = []    
    view = open(view_path, "w")
    view.puts "class #{view_name} \n"
    view.puts "  def show \n"

    tmpl = open(tmpl_path)
    tmpl.each do |line|
      # 使用しているインスタンス変数を洗い出す
      vars.concat(line.scan(/@([_0-9a-z]+)/i))    
      # !{ }内はRubyのステートメントに置換
      if line =~ /!\{.+\}/    
        view.puts '    ' + line.gsub(/!\{(.+)\}/, '\1')
      else    
        # それ以外は加工してprintさせる
        # ダブルクォートのエスケープ
        line.gsub!(/"/, '\"')    
        # HTMLエスケープ
        line.gsub!(/%\{([^\}]+)\}/, '#{CGI.escapeHTML(\1.to_s)}')    
        view.puts '    print "' + line.rstrip + '\n"'
      end
    end
    tmpl.close

    view.puts "  end \n"
    view.puts "  attr_accessor :" + vars.uniq.join(", :") if vars.size > 0
    view.puts "end \n"
    view.close
  end
end

class SetupXML
  require "date"

  # XMLをテンプレート取得->View生成->Viewのインスタンス生成->ファイル出力する制御処理
  # ==== Args
  # _options _ :: Redmineチケット｡省略可能｡
  # ==== Return
  # ==== Raise
  def self.arrange_and_put(options = nil, tmpl_path = nil)
    if options.nil?
      xml = SetupXML.get("#{Dir.pwd}/georss1_0.tmpl", :mime_type => "application/rss+xml")
    else
      xml = SetupXML.get("#{Rails.root.to_s}/plugins/lgdis/lib/lgdis/ext_out/georss1_0.tmpl", :mime_type => "application/rss+xml")
    end
    base_url          = xml.site_url
    xml.site_url    += "/r/feed/"
    #TODO 注:UUIDはversion 1 [時刻とノードをベースにした一意値]を生成,centOS依存
    xml.uuid        = `uuidgen`.chomp

    if options.nil?
      xml.title       = "Simple-geoRSS1.0(ATOM)のテスト"
      xml.subtitle    = "ref: http://georss.org/simple"
      xml.author      = "Dr. Thaddeus Remor"
      xml.authormail  = "tremor@quakelab.edu"
      time            = Time.now.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.items = [ {
        :url       => base_url + "/page1",
        :title     => "ページ1",
        :uuid      => `uuidgen`.chomp,
        :description => "1つ目のページ",
        :date      => time,
        :point     => "45.256 -71.92",
        :line      => "45.256 -110.45 46.46 -109.48 43.84 -109.86",
        :polygon   => "45.256 -110.45 46.46 -109.48 43.84 -109.86 45.256 -110.45"
      } ]
      # RSS1出力にに複数entryをもたせたいときの予備コード
      #             {:url      => base_url + "/page2",
      #              :title    => "ページ1",
      #              :description => "2つ目のページ",
      #              #日付はDateTimeオブジェクトで渡す
      #             },
      outfile = "/opt/LGDIS/public/atom/#{time}-geoatom.rdf"
    else

      issue           = options
      xml.title       = "#{issue.project.name}"
      xml.subtitle    = "ref: http://georss.org/simple"
      xml.author      = issue.author.name
      xml.authormail  = issue.author.mail
      time            = Time.now.strftime("%Y-%m-%dT%H:%M:%SZ")

      #世界測地系出力フラグ
      geodetic_system_name ="wgs" 
      #地理情報関連の変数初期化
      indents="\t\t\t" ;  strbuf="";  cnt_geo=1
      # point  列の内容を  <georss:pointタグ対象に
      # line   列の内容を   <georss:lineタグ対象に
      # polygon列の内容を<georss:polygonタグ対象に
      # gem Jpmobile::DatumConvで測地系に一律変換してから変数に追記する
      issue.issue_geographies.each{|i| 
        strbuf += indents + "<!---------- 本件についての地理情報 No." + cnt_geo.to_s + " ---------->\n"
        tgt=i.point.to_s
        strbuf += indents + "<georss:point>" + fix_geo_str(tgt,geodetic_system_name,"line").chop + "</georss:point>\n" 
        tgt=i.line.to_s
        strbuf += indents + "<georss:line>" + fix_geo_str(tgt,geodetic_system_name,"line").chop + "</georss:line>\n"
        tgt=i.polygon.to_s
        strbuf += indents + "<georss:polygon>" + fix_geo_str(tgt,geodetic_system_name,"polygon").chop + "</georss:polygon>\n"
        
        strbuf += indents + "<georss:featureTypeTag>" + i.location.to_s + "</georss:featureTypeTag>\n"

        strbuf += indents + "<georss:relationshipTag>iconfile=" + rand(16).to_s + "-dot.png</georss:relationshipTag>\n"
        cnt_geo += 1
      }
      #descriptionはtwitterにあわせて140文字制限｡今は単純に説明文だけを出力している
      
      web_fqdn = Socket.gethostbyname(Socket.gethostname).first.to_s
#     :url       => "http://#{web_fqdn}/issues/#{issue.id}",
      xml.items = [ {
         :title     => "#{issue.tracker.name} ##{issue.id}: #{issue.subject}",
         :uuid      => `uuidgen`.chomp,
         :date      => time,
         :description => issue.description.to_s[0,140] ,
         :geoinfo   => strbuf
      } ]
      outfile = "#{Rails.root.to_s}/public/atom/#{time}-geoatom.rdf"
    end

    #simple-geoRSS(ATOM) コンソール出力　
    xml.show #if options.nil?
debugger
    return xml

    #simple-geoRSS(ATOM)ファイル出力　
#     outfile = "#{Rails.root.to_s}/public/atom/#{time}-geoatom.rdf"
    stdout_old = $stdout.dup 
    open(outfile, "w+b") do |f|
      $stdout.reopen(f)
      xml.show
    end
    $stdout.flush;$stdout.reopen stdout_old 

  end


private
  # Y座標(経度) X座標(緯度)の順で記述された地理座標をX座標(緯度)Y座標(経度)の順に変換 
  # ==== Args
  # _str_geodetic_ :: y,x y,x y,x...の順の座標文字列
  # _geodetic_system_name_ :: 測地系種別文字列 wgs か sekaisokutikei ならば世界測地系 
  # _mode_ :: point, line, polygonの種別
  # ==== Return
  # _strtmp_ :: x,y x,y x,y....の順の座標文字列
  # ==== Raise
  def self.fix_geo_str(str_geodetic, geodetic_system_name, mode ="")
    strtmp=""
    if mode =~/point/
      ary_xy = str_geodetic.gsub(  /[\(\)\s]/,"").split(",").reverse
      return fix_datum(ary_xy, geodetic_system_name) 
    else
      str_geodetic.gsub(/^\(+|\)+\s*$/,"").split(/^\(|\)$|\), *\(/).each{|j|
        ary_pol= j.gsub(/^\(+|\)+\s*$/,"").split(/^\(|\)$|\), *\(/)
        ary_pol.each{|k| 
          ary_xy = k.split(/\s*,\s*/).reverse
          strtmp += fix_datum(ary_xy, geodetic_system_name) + " "
        }
      }
      return strtmp
    end
  end
    
  # 座標の測地系に応じた補正処理
  # ==== Args
  # _ary_xy_ :: x座標y座標を格納した配列
  # _geodetic_system_name_ :: 測地系種別文字列 wgs か sekaisokutikei ならば世界測地系 
  # ==== Return
  # __ :: 日本測地系ならば x y座標文字列､ 世界測地系ならば補正されたx y座標
  # ==== Raise
  def self.fix_datum(ary_xy, geodetic_system_name )
    if ary_xy.blank? then 
      return ""
    elsif geodetic_system_name =~/(wgs|sekaisokutikei)/ then
      y,x = DatumConv.tky2jgd(ary_xy[0].to_f,ary_xy[1].to_f) 
      return  y.to_s + " " + x.to_s
    else
      return  ary_xy.join(" ") 
    end
  end

  # Railsの*.erbテンプレートの様に､テンプレートからXMLを生成する
  # ==== Args
  # _tmpl_path_ :: XMLテンプレートのファイルシステム上のフルパス｡
  # ==== Return
  # _xml_ :: 不定タグ内容を代入できる属性として持つxml出力雛形
  # ==== Raise
  def self.get(tmpl_path, options = {})
    #CGI off-line mode回避用ダミーコード:最後にコントロールDを入れる作業を回避
    ARGV.replace(%w(abc=001 def=002))  

    cgi = CGI.new
    mime_type = options[:mime_type] || "application/xml"
    encoding = options[:encoding] || "utf-8"
    language = options[:language] || "ja"

    xml = Template.get(tmpl_path, {"type" => mime_type, "charset" => encoding})
    xml.encoding = encoding
    xml.site_url = "http://www.w3.org/2005/Atom" + cgi.server_name.to_s
    xml.updated  = Time.now.strftime("%Y-%m-%dT%H:%M:%SZ")
    #予備項目
    #xml.language = language
    #xml.feed_url = xml.site_url + cgi.script_name if xml.methods.include?("feed_url")
    return xml
  end
end

if __FILE__ == $0
  SetupXML.arrange_and_put
end


#debugcodes  
  #v.items[0][:title]
  #date format = 2005-08-17T07:02:32Z   
  #SetupXML.get('/opt/redmine/plugins/lgdis/lib/lgdis/ext_out/rss1_0.tmpl', :mime_type => "application/rss+xml")
	#ary_pol= "((-110.45 , 45.256), (-109.48,46.46),(-109.86,43.84),(-110.45,45.256))".gsub(/^\(+|\)+\s*$/,"").split(/^\(|\)$|\), *\(/)

# -*- encoding: utf-8 -*-

#Simple-geoATOM I/F スクリプト本体のつかいかた:
#スクリプトとしてつかうばあいは ruby feeder.rb
#Railsコンソールから呼ぶ場合は､RedmineのIssueオブジェクトを引数にして以下の様に呼び出す;
#    例: SetupXML.arrange_and_put(Issue.first)

#Simple-geoATOM テンプレートファイル "*.tmpl"のメタタグ記法
# #{ }でそのまま出力
# %{ }でHTMLエスケープして出力
# !{ }内はRubyのコードとして実行する
# データはインスタンス変数としてセットされるので@で使える


require "cgi"

class Template
    # テンプレートから作成したViewを取得する
    def self.get(tmpl_path, http_headers = "text/html")
        view_path = tmpl_path + ".view.rb"    # Viewのファイルパス
        # Viewのクラス名
        view_name = "View_" + tmpl_path.sub(/^.+\//,"").gsub(/[-.]/, "_")    
        # Viewクラスがまだ無いか、テンプレートより古い場合はViewクラスを作成する
        if !FileTest.exist?(view_path) || File::stat(tmpl_path).mtime > File::stat(view_path).mtime
            self.create_view(tmpl_path, view_path, view_name)
        end
        #Viewクラスを読み込む
        load view_path    
        # HTTPヘッダ出力
        print CGI.new.header(http_headers)    
        # Viewのインスタンスを返す
        return eval(view_name + ".new")    
    end
 
    # Viewクラスを定義するファイルを生成する
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
    def self.arrange_and_put(options = nil, template_path = nil)
      xml = SetupXML.get('/opt/LGDIS/plugins/lgdis/lib/lgdis/ext_out/rss1_0.tmpl', :mime_type => "application/rss+xml")
      base_url          = xml.site_url
        xml.site_url    += "/r/feed/"
        #注:UUIDはversion 1 [時刻とノードをベースにした一意値]を生成,centOS uuidgenコマンド依存
        xml.uuid        = `uuidgen`.chomp

      if options.nil?
        #case when options == nil
        xml.title       = "Simple-geoRSS1.0(ATOM)のテスト"
        xml.subtitle    = "ref: http://georss.org/simple"
        xml.author      = "Dr. Thaddeus Remor"
        xml.authormail  = "tremor@quakelab.edu"
        time            = Time.now.strftime("%Y-%m-%dT%H:%M:%SZ")
#予備コード
#             {:url      => base_url + "/page2",
#              :title    => "ページ1",
#              :description => "2つ目のページ",
#              #日付はDateTimeオブジェクトで渡す
#              :date     => time,
#              :point    => "45.256 -71.92",
#              :line     => "45.256 -110.45 46.46 -109.48 43.84 -109.86",
#              :polygon  => "45.256 -110.45 46.46 -109.48 43.84 -109.86 45.256 -110.45"
#             },
        xml.items = [
            {:url       => base_url + "/page1",
             :title     => "ページ1",
             :uuid      => `uuidgen`.chomp,
             :description => "1つ目のページ",
             :date      => time,
             :point     => "45.256 -71.92",
             :line      => "45.256 -110.45 46.46 -109.48 43.84 -109.86",
             :polygon   => "45.256 -110.45 46.46 -109.48 43.84 -109.86 45.256 -110.45"
            }
        ]
        outfile = "/opt/LGDIS/public/atom/#{time}-geoatom.rdf"
      else
        #case when options != nil  : ref:/#{Rails.root}/app/views/journals/index.builder
        issue           = Issue.first
        xml.title       = "#{issue.project.name}"
        xml.subtitle    = "ref: http://georss.org/simple"
        xml.author      = issue.author.name
        xml.authormail  = issue.author.mail
        time            = Time.now.strftime("%Y-%m-%dT%H:%M:%SZ")

        cnt_point = issue.issues_additional_data.size
        #switch xy.size
        if cnt_point > 0 then
          latitude1     = issue.issues_additional_data[0].latitude.to_s
          longitude1    = issue.issues_additional_data[0].longitude.to_s
          str_xy1       = latitude1 + " " + longitude1 
        end
        if cnt_point >= 2 then
          #case of non-geo-point
          latitude2     = issue.issues_additional_data[1].latitude.to_s
          longitude2    = issue.issues_additional_data[1].longitude.to_s
          str_xy2       = str_xy1 + " " + latitude2 + " " + longitude2
          if cnt_point  > 2 then
            #case of polygon
            str_xy3=""
            issue.issues_additional_data.each {|i|
              str_xy3   += i.latitude.to_s + " " + i.longitude.to_s + " "
            }
          end
        end

        #descriptionはtwitterにあわせて140文字制限を想定｡今は単純に説明文だけを出力している　#"1234567890"*14,
        xml.items = [
            {:url       => href="/issues/#{issue.id}",
             :title     => "#{issue.tracker.name} ##{issue.id}: #{issue.subject}",
             :uuid      => `uuidgen`.chomp,
             :description => issue.description.to_s[0,140] ,
             :date      => time,
             :point     => str_xy1.to_s ,
             :line      => str_xy2.to_s  , 
             :polygon   => str_xy3.to_s 
            }
        ]
        outfile = "#{Rails.root.to_s}/public/atom/#{time}-Sent.log"
      end

      #k-takami simple-geoRSS(ATOM)出力例:　
      stdout_old = $stdout.dup 
      open(outfile, "w+b") do |f|
        $stdout.reopen(f)
        xml.show
      end
      $stdout.flush;$stdout.reopen stdout_old 

      xml.show #if options.nil?

    end

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
#         xml.language = language
#         xml.feed_url = xml.site_url + cgi.script_name if xml.methods.include?("feed_url")
        return xml
    end
end

if __FILE__ == $0
  SetupXML.arrange_and_put
end

#JMA-XML tags examples:  ref:vimgrep /\(ol.gon\|ine\|oint\)/ **/*xml
  #line    tag =  # <westBoundLongitude>140.250000</westBoundLongitude> 
                  # <eastBoundLongitude>141.750000</eastBoundLongitude> 
                  # <southBoundLatitude>37.750000</southBoundLatitude>
                  # <northBoundLatitude>39.083333</northBoundLatitude>
  #point   tag = <gml:Point gml:id="PT_02367"><gml:pos>38.75053389 141.26430417</gml:pos></gml:Point>
          #poligon tag = <gml:posList>
#debugcodes  
  #v.items[0][:title]
  #date format = 2005-08-17T07:02:32Z   
  #debugger  SetupXML.get('/opt/redmine/plugins/lgdis/lib/lgdis/ext_out/rss1_0.tmpl', :mime_type => "application/rss+xml")


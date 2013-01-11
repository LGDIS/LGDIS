class IfCommon
  def leave_log(msg)
    begin
      # アーカイブログ出力例:　
      #TODO:　 mkdir #{ClassName} ; chown apl:apl #{iClassName}/　
      #というディレクトリー作成と所属設定を自動化が理想的
      time     = Time.now.strftime("%Y-%m-%d-%H:%M:%S")
      methodParentName="LGDIS"   
      outfile="#{Rails.root.to_s}/log/#{methodParentName}/#{time}-Sent.log" 
      File.open(outfile, "w+b", 0644){|f| f.write(msg) } 
#       Rails.logger.info("IFCOMMON: #{(msg)}")

    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{create_log_time(msg, modulename)}")
    ensure

    end
  end

  def create_log_time(msg,modulename)
    time     = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    time  = "[" + "#{time}" + "]" + "[" + "#{modulename}" + "]" + " \"" + \
               "#{msg}" + "\""
    return time
  end

end

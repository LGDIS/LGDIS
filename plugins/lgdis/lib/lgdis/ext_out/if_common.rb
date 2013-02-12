# -*- encoding: utf-8 -*-
class IfCommon

  def leave_log(msg)
    modulename="if_common"
    begin
      # アーカイブログ出力例:　
      #TODO:　 mkdir #{ClassName} ; chown apl:apl #{iClassName}/　
      #というディレクトリー作成と所属設定を自動化が理想的
      time     = Time.now.strftime("%Y-%m-%d-%H:%M:%S")
      methodParentName="LGDIS"   
      outfile="#{Rails.root.to_s}/log/#{methodParentName}/#{time}-Sent.log" 
      File.open(outfile, "w+b", 0644){|f| f.write(msg) } 
      #Rails.logger.info("IFCOMMON: #{(msg)}")
      status = true
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}" + "\n" + \
                         "#{create_log_time(msg, modulename)}")
      status = false
    ensure
      return status 
    end
  end

  def create_log_time(msg,modulename)
    time     = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    time  = "[" + "#{time}" + "]" + "[" + "#{modulename}" + "]" + " \"" + \
               "#{msg}" + "\""
    return time
  end

  def mail_when_delivery_fails
    # エラー時のメール配信
    modulename="if_common"
    o = IfCommon.new
    begin
      alert_to = DST_LIST['outbound_alert_mailto'].to_s
      title_prefix = DST_LIST['outbound_alert_title_prefix'].to_s + Time.now.xmlschema+" "
      msg = DST_LIST['alert_msg'].to_s
      account = DST_LIST['smtp_auth_server_conf']['account']
      pw = DST_LIST['smtp_auth_server_conf']['password']

      if account.present? || pw.present?
        #tls =  DST_LIST['smtp_auth_server_conf']['tls']
        status2 = Lgdis::ExtOut::Mailer.setup_auth( alert_to,title_prefix, msg).deliver
      else
        status2 = Lgdis::ExtOut::Mailer.setup( alert_to,title_prefix, msg).deliver
      end
      o.create_log_time(status2.to_s + "\n", modulename) if status2.class != Mail::Message
    rescue => e
      str_tmp = "#{e.backtrace.join("\n")}\n#{o.create_log_time(msg,modulename)}"
      Rails.logger.error(str_tmp); puts str_tmp
    end
  end

end

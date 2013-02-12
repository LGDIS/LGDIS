# -*- encoding: utf-8 -*-
class Lgdis::ExtOut::SOAP_KJcommons  < ActiveRecord::Base
# 処理概要:
# 配信管理モジュール側からはREXMLにロードした状態ででXML(PCXML)オブジェクトが引き渡されることを前提とする 
# Gemfileでrequireされたcommon_client.rbで､
# XML(PCXML)の周辺をSOAPヘッダータグとWS-Security認証タグで包んで
# 最後にコモンズWSDLで定義されたpublishメソッドを呼んで送信している｡ 

# IRBコンソールでの呼び出し例: 
#   引数0に読ませたいPCXMLファイル名をわたしてREXMLにロードする例:
#   Lgdis::ExtOut::SOAP_KJcommons.send_message(REXML::Document.new(File.open("#{Rails.root.to_s}/plugins/lgdis/lib/lgdis/ext_out/adsoltestbest.xml")),false)

  def self.send_message(msg, test_flg)
    modulename="SOAP_KJcommons"
    o = IfCommon.new

    begin
      if test_flg.blank?
        if DST_LIST['commons_user'].present?
          endpoint=DST_LIST['commons_endpoint']
          usename, password = [DST_LIST['commons_user'], DST_LIST['commons_pw']]
          wsdl = DST_LIST['commons_wsdl']
          namespace = DST_LIST['commons_namespace']
        else
          endpoint="http://192.168.43.186/commons/subscriber/soap/testservice.example.com/"
          usename, password = ['user1@example.com','password']
          pwd="#{Redmine::Plugin.registered_plugins[:lgdis].directory}/lib/lgdis/ext_out"
          wsdl = "#{pwd}/wsdl/MQService.wsdl"
          namespace = 'http://soap.publiccommons.ne.jp/'
        end

        client = CommonsClient.new( wsdl, endpoint, namespace)
        client.set_auth(usename, password)
        client.send(msg)
      end
      #TODO: アーカイブ出力に関して、課題検討中? 現在はlogger で対応
      Rails.logger.info("#{o.create_log_time(msg,modulename)}")
      status = true
      
      #TODO: Issue(=Ticket)画面に処理ステータス書き込み
      #msg = summary['message'].blank? ? summary : summary['message']
      #journal = issue.init_journal(User.current, msg)

    rescue => e
      str_tmp = "#{e.backtrace.join("\n")}\n#{o.create_log_time(msg,modulename)}"
      Rails.logger.error(str_tmp); msgputs str_tmp
      #TODO: エラー時のメール配信
      #aenque処理で
      # =>
      status = false
    ensure
      #アーカイブログ出力　
      o.leave_log(msg)
      return status 
    end
  end

end


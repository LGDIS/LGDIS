# -*- encoding: utf-8 -*-
# 公共情報コモンズにSOAPメッセージを送信する制御プログラム
#
# 作動条件:
# 配信管理モジュール側からREXMLに読み込んだXML(PCXML)オブジェクトが引き渡されること｡ 

# IRBコンソールでの呼び出し例: 
#   引数0に読ませたいPCXMLファイル名をわたしてREXMLにロードする例:
#   Lgdis::ExtOut::SOAP_KJcommons.send_message(REXML::Document.new(File.open("#{Rails.root.to_s}/plugins/lgdis/lib/lgdis/ext_out/adsoltestbest.xml")),false)

class Lgdis::ExtOut::SOAP_KJcommons  < ActiveRecord::Base

  # I/Fよびだし処理 非同期処理にはResqueを使用)
  # 最後にログ出力をし､戻り値を返す
  # 処理中にエラーがあれば､destination_list.ymlで設定された
  # SMTPサーバーとalert先にメール通知をする
  # ==== Args
  # _msg_ :: 送信先､表題､メッセージ本文を含んだハッシュ(=連想配列)
  # _test_flg_ :: 試験モードフラグ
  # _issue_ :: Redmineチケット
  # ==== Return
  # _status_ :: 戻り値
  # ==== Raise
  def self.send_message(msg, test_flg, issue=nil)
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
          endpoint="http://***.***.***.***/commons/subscriber/soap/testservice.example.com/"
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

      #raise #=> RuntimeError:
      status = true
    rescue => e
      str_tmp = "#{e.backtrace.join("\n")}\n#{o.create_log_time(msg,modulename)}"
      Rails.logger.error(str_tmp); puts str_tmp
      status = false
      # エラー時のメール配信 -> if_common.rbのメソッドを呼び出す
      o.mail_when_delivery_fails
    ensure
      #アーカイブログ出力　  -> if_common.rbのメソッドを呼び出す
      o.leave_log(msg)
      print "\n"
      return status 
    end
  end

end


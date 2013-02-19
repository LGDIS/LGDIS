# -*- encoding: utf-8 -*-
# 公共情報コモンズにWS-Security UsernameToken認証対応
# EDXLDE形式SOAPメッセージを生成するプログラム本体
#
# XML(PCXML)の周辺をSOAPヘッダータグとWS-Security認証タグで包んで
# 最後にコモンズWSDLで定義されたpublishメソッドを呼んで送信している｡ 
#
# 作動条件: Rails.root/plugins/lgdis/Gemfileでrequireされていること｡
#
class SoapKjCommonsRequestJob
  @queue = :soap_kj_commons_request

  # I/Fよびだし処理 非同期処理にはResqueを使用
  # 最後に戻り値を返す
  # ==== Args
  # _msg_ :: 送信先､表題､メッセージ本文を含んだハッシュ(=連想配列)
  # _test_flg_ :: 試験モードフラグ
  # _issue_ :: Redmineチケット
  # ==== Return
  # _status_ :: 戻り値
  # ==== Raise
  def self.perform(msg, test_flg, issue, delivery_history=nil)
    o = IfCommon.new
    begin
      str= "##################################### 公共情報コモンズWORKER がよばれました\n"
      Rails.logger.info("#{str}");print("#{str}")
      status = Lgdis::ExtOut::SoapKjCommons.send_message(msg, test_flg)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}\n")
      status = false
      # エラー時のメール配信 -> if_common.rbのメソッドを呼び出す
      o.mail_when_delivery_fails
    ensure
      # 配信ステータスの更新
      delivery_history.update_attributes(:status => (status == false ? 'failed' : 'done'))
      #アーカイブログ出力　  -> if_common.rbのメソッドを呼び出す
      o.leave_log(msg); print "\n"
      o.register_edition(issue) if status != false
      o.feedback_to_issue_screen(msg, issue, delivery_history, status)
      return status
    end
  end

end


# -*- encoding: utf-8 -*-
# 公共情報コモンズにWS-Security UsernameToken認証対応
# EDXLDE形式SOAPメッセージを生成するプログラム本体
#
# XML(PCXML)の周辺をSOAPヘッダータグとWS-Security認証タグで包んで
# 最後にコモンズWSDLで定義されたpublishメソッドを呼んで送信している｡ 
#
# 作動条件: Rails.root/plugins/lgdis/Gemfileでrequireされていること｡
#
class SOAP_KJcommonsRequestJob
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
  def self.perform(msg, test_flg, issue)
    begin
      # TODO
      # XML からUUID, 版番号を取得する
      str= "##################################### 公共情報コモンズWORKER がよばれました\n"
      Rails.logger.info("#{str}");print("#{str}")
      status = Lgdis::ExtOut::SOAP_KJcommons.send_message(msg, test_flg)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}\n")
      status = false
    ensure
      register(issue) if status
      return status
    end
  end

  # 文書改版管理処理｡取り消しされた場合はDocumentID(=UUID)を発番し
  # 版番号を1にリセットする｡
  # ==== Args
  # _issue_ :: Redmineチケット
  # ==== Return
  # ==== Raise
  def register(issue)
    project_id = issue.project_id
    tracker_id = issue.tracker_id
    # カスタムフィールドが固まるまでの仮実装
#    type_update = issue.custom_field_value(DST_LIST['custom_field_delivery']['type_update'])
    type_update = 1

    edition_mng = EditionManagement.find_by_project_id_and_tracker_id(project_id, tracker_id)
    # 新規追加処理
    if edition_mng.blank?
      EditionManagement.create(:project_id => project_id,
                               :tracker_id => tracker_id,
                               :issue_id   => issue.id,
                               :uuid       => 'uuid')
    else
      edition_status = 1
      edition_status = 0 if type_update=='cancel'
      # 直近の配信で、配信取消されていた場合は、版番号を振りなおす
      # それ以外は版番号をインクリメント
      edition_num = edition_mng.status == 0 ? 1 : edition_mng.edition_num+=1
      edition_mng.update_attributes(:status      => edition_status,
                                    :edition_num => edition_num)
    end
  end
end


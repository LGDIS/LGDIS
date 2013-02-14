# coding: utf-8
class SOAP_KJcommonsRequestJob
  @queue = :soap_kj_commons_request

  def self.perform(msg_hash, test_flg, issue)
    begin
      # TODO
      # XML からUUID, 版番号を取得する
      str= "##################################### 公共情報コモンズWORKER がよばれました\n"
      Rails.logger.info("#{str}");print("#{str}")
      status = Lgdis::ExtOut::SOAP_KJcommons.send_message(msg_hash, test_flg)
    rescue => e
      Rails.logger.error("#{e.backtrace.join("\n")}\n")
      status = false
    ensure
      register(issue) if status
      return status
    end
  end

  def register(issue)
    project_id = issue.project_id
    tracker_id = issue.tracker_id
    # カスタムフィールドが固まるまでの仮実装
#    type_update = issue.custom_field_value_by_id(DST_LIST['custom_field_delivery']['type_update'])
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


# -*- encoding: utf-8 -*-
# 外部配信機能共通処理クラス
#
class IfCommon

  # ログファイルをのこす｡｢アーカイブ｣的意味をもつ｡
  # ==== Args
  # _msg_ :: 任意のオブジェク｡通常は文字列を想定している｡
  # ==== Return
  # _status_ :: 戻り値 正常終了はTrue, 異常終了はFalseを返す
  # ==== Raise
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

  # ログファイル出力内容の整形
  # ==== Args
  # _msg_ :: 記録内容主部
  # _modulename_ :: 記録対象がどこで発生したかを示す文字列
  # ==== Return
  # _strnew_ :: 年月日時分秒､モジュール名､記録内容主部を連結した文字列
  # ==== Raise
  def create_log_time(msg,modulename)
    time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    strnew= "[" + "#{time}" + "]" + "[" + "#{modulename}" + "]" + " \"" + \
               "#{msg.to_s}" + "\""
    return strnew
  end

  # 外部配信エラー時のメールによる通報処理
  # この通報処理自体がエラーになったときはログファイルに記録する｡
  # ==== Args
  # __ :: 引数はなく､plugin/lgdis/config/destination_list.ymlの設定値で通報設定をする｡
  # ==== Return
  # ==== Raise
  def mail_when_delivery_fails
    modulename="if_common"
    begin
      alert_to = DST_LIST['disruption_alert_mailto'].to_s
      title_prefix = DST_LIST['disruption_alert_title_prefix'].to_s + Time.now.xmlschema+" "
      msg = DST_LIST['disruption_alert_msg'].to_s
      account = DST_LIST['smtp_server3']['account']
      pw = DST_LIST['smtp_server3']['password']
      if account.present? || pw.present?
        status2 = Lgdis::ExtOut::MailerExtra.setup_auth( alert_to, title_prefix, msg).deliver
      else
        status2 = Lgdis::ExtOut::MailerExtra.setup( alert_to, title_prefix, msg).deliver
      end
      create_log_time(status2.to_s + "\n", modulename) if status2.class != Mail::Message
    rescue => e
      str_tmp = "#{e.backtrace.join("\n")}\n#{create_log_time(msg,modulename)}"
      Rails.logger.error(str_tmp); puts str_tmp
    end
  end

  # チケットへの送信履歴書き込み処理
  # ==== Args
  # _msg_ :: 
  # _modulename_ :: 記録対象がどこで発生したかを示す文字列
  # _issue_ ::: 
  # ==== Return
  # _strnew_ :: 年月日時分秒､モジュール名､記録内容主部を連結した文字列
  # ==== Raise
  def feedback_to_issue_screen(msg, issue, delivery_history=nil, status)
    tgt  = DST_LIST['destination_name'][delivery_history.delivery_place_id].to_s
    dhid = delivery_history.nil? ? "" : "No. " + delivery_history.id.to_s
    notes = ""

    case msg
    when String, Hash
      notessuffix = "\n#{msg.to_s}"
    when NIL
    else
      if msg.elements["//edxlde:dateTimeSent"].present?
        notes = msg.elements["//edxlde:dateTimeSent"].text 
        notes = notes.to_s.to_datetime.strftime("%Y/年%m月%d日 %H時%M分%S秒の")
      end
    end
    notes += "配信要求#{dhid} #{tgt}むけの結果は"
    notes += (status != false) ? "正常でした" : "エラーでした"
    notes += notessuffix.to_s
    current_journal =  Journal.find_by_sql(
      "select * from journals where journalized_id = #{issue.id} 
      and notes like '%#{dhid}%#{tgt}%' limit 1"
    )
    return issue.init_journal(User.current, notes )
  end

  # 文書改版管理処理｡取り消しされた場合はDocumentID(=UUID)を発番し
  # 版番号を1にリセットする｡
  # ==== Args
  # _issue_ :: Redmineチケット
  # ==== Return
  # ==== Raise
  def register_edition(issue) 
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

#debugcode
# Journal.find_all_by_journalized_id(issue.id).each{|l| p l}

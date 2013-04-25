# encoding: utf-8
class DeliveryHistory < ActiveRecord::Base
  unloadable

  belongs_to :project
  belongs_to :issue
  belongs_to :request_user, :class_name => "User", :foreign_key => :request_user_id
  belongs_to :respond_user, :class_name => "User", :foreign_key => :respond_user_id

  attr_accessible :issue_id, :project_id, :delivery_place_id, :status, :process_date,
                  :mail_subject, :summary, :type_update, :description_cancel, :published_at,
                  :delivered_area, :opened_at, :closed_at, :disaster_info_type, :request_user_id, :respond_user_id

  validates :published_at, :custom_format => {:type => :datetime}
  validates :opened_at, :custom_format => {:type => :datetime}
  validates :closed_at, :custom_format => {:type => :datetime}
  validate :for_commons

  # 外部配信先ID
  COMMONS_ID    =  1
  SMTP_0_ID     =  2
  SMTP_1_ID     =  3
  SMTP_2_ID     =  4
  SMTP_3_ID     =  5
  SMTP_AUTH_ID  =  6
  TWITTER_ID    =  7
  FACEBOOK_ID   =  8
  ATOM_ID       =  9
  U_MAIL_DCM_ID = 10
  U_MAIL_SB_ID  = 11
  U_MAIL_AU_ID  = 12

  # 更新種別ステータス
  NEW_STATUS    = '1'
  UPDATE_STATUS = '2'
  CANCEL_STATUS = '3'

  # 属性のローカライズ名取得
  # validateエラー時のメッセージに使用されます。
  # "field_" + 属性名 でローカライズします。
  # ※"summary"の場合、既存の翻訳ファイルと重複するため、"plugin_"を接頭辞として追加する。
  # ==== Args
  # _attr_ :: 属性名
  # _args_ :: args
  # ==== Return
  # 項目名
  # ==== Raise
  def self.human_attribute_name(attr, *args)
    attr = "plugin_#{attr}" if attr.to_s == "summary"
    l("field_#{name.underscore.gsub('/', '_')}_#{attr}", :default => ["field_#{attr}".to_sym, attr])
  end

  # 配信履歴テーブル作成処理
  # 外部配信先により、バリデーションが異なる為issue では
  # バリデーション処理が行えないものがある。
  # その為、配信履歴テーブルにsave しバリデーションを行う
  # issue の拡張項目と同じものを登録
  # ==== Args
  # _issue_ :: チケットオブジェクト
  # _ary_ :: 外部配信先ID の配列
  # ==== Return
  # 項目名
  # ==== Raise
  def self.create_for_history(issue, ary)
    deliver_histories = []
    ary.each do |e|
      x = self.new(
        :issue_id          => issue[:id],
        :project_id        => issue[:project_id],
        :delivery_place_id => e.to_i,
        :request_user_id   => User.current.id,
        :status            => 'request',
        :process_date      => Time.now,
        :mail_subject      => issue[:mail_subject],
        :summary           => issue[:summary],
        :type_update       => issue[:type_update],
        :description_cancel=> issue[:description_cancel],
        :delivered_area    => issue[:delivered_area],
        :published_at      => issue[:published_at],
        :opened_at         => issue[:opened_at],
        :closed_at         => issue[:closed_at],
        :disaster_info_type=> issue[:disaster_info_type])
      x.save
      deliver_histories << x
    end
    return deliver_histories
  end

  # コモンズ向け配信か？
  # ==== Args
  # ==== Return
  # true/false
  # ==== Raise
  def for_commons?
    ids = DST_LIST['delivery_place_group_commons'].map{|i| i["id"]}
    return ids.include?(delivery_place_id)
  end
  # 緊急速報メール向け配信か？
  # ==== Args
  # ==== Return
  # true/false
  # ==== Raise
  def for_urgent_mail?
    ids = DST_LIST['delivery_place_group_urgent_mail'].map{|i| i["id"]}
    return ids.include?(delivery_place_id)
  end
  # ATOM(RSS)作成配信か？
  # ==== Args
  # ==== Return
  # true/false
  # ==== Raise
  def for_atom?
    ids = DST_LIST['delivery_place_rss'].map{|i| i["id"]}
    return ids.include?(delivery_place_id)
  end

  # resque-schedulerへの配信可否を判定
  # ==== Args
  # ==== Return
  # true/false
  # ==== Raise
  def schedulable?
    case
    when for_commons? || for_urgent_mail?
      # コモンズ/緊急速報メールの場合、配信用宮中であれば許可
      return (status == 'request')
    when for_atom?
      # ATOM(RSS)の場合は外部配信対象外なので不可
      return false
    else
      # 上記以外(Twitter/Facebook/各種メール)の場合、配信要求中であれば許可
      return (status == 'request')
    end
  end

  # 取り消し可否を判定
  # ==== Args
  # ==== Return
  # true/false
  # ==== Raise
  def rejectable?
    case
    when for_commons? || for_urgent_mail?
      # コモンズ/緊急速報メールの場合は不可
      return false
    when for_atom?
      # ATOM(RSS)の場合は不可
      return false
    else
      # 上記以外(Twitter/Facebook/各種メール)の場合、取り消し可能なステータスであれば許可
      return (status == 'request' || status == 'reserve')
    end
  end

  # 配信確認リンク可否を判定
  # ==== Args
  # ==== Return
  # true/false
  # ==== Raise
  def allow_delivery?
    return (status == 'request' || status == 'reserve')
  end

  # 配信確認画面で「配信許可」「配信却下」ボタンの表示を許可するかを判定
  # ※実際のボタン描画時には、ログインユーザに配信管理権限があるかの判定を加える必要がある
  # ==== Args
  # ==== Return
  # true/false
  # ==== Raise
  def allow_delivery_control?
    return (status == 'reserve')
  end

  # ステータスを「配信中」に変更
  # ==== Args
  # ==== Return
  # ==== Raise
  def set_runtime_status
    update_attributes!(status: 'runtime')
  end

  private

  # コントロールプレーン部バリデーション処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def for_commons
    if ((DST_LIST['general_info_ids'].include?(self.issue.tracker_id)) && [COMMONS_ID].include?(self.delivery_place_id)) ||
       ((DST_LIST['events_ids'].include?(self.issue.tracker_id)) && [COMMONS_ID].include?(self.delivery_place_id)) ||
       ([U_MAIL_DCM_ID, U_MAIL_AU_ID, U_MAIL_SB_ID].include?(self.delivery_place_id))
    	edition_mng = EditionManagement.find_by_issue_id_and_delivery_place_id(self.issue.id, self.delivery_place_id)
    else
    	edition_mng = EditionManagement.find_by_project_id_and_tracker_id_and_delivery_place_id(self.issue.project_id, self.issue.tracker_id, self.delivery_place_id)
    end

    if ([SMTP_0_ID, SMTP_1_ID, SMTP_2_ID, SMTP_3_ID, SMTP_AUTH_ID, ATOM_ID,
         U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) && self.mail_subject.blank?
      errors.add(:mail_subject, "を入力して下さい")
    end

    if ([SMTP_AUTH_ID, TWITTER_ID, FACEBOOK_ID, ATOM_ID,
         U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) && self.summary.blank?
      errors.add(:summary, "を入力して下さい")
    end

    if ([TWITTER_ID, ATOM_ID].include?(self.delivery_place_id)) && self.summary.size >= (142 - DST_LIST['disaster_portal_url'].size)
      errors.add(:summary, "は#{142 - DST_LIST['disaster_portal_url'].size}文字以上入力できません")
    end

    if ([U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) && self.mail_subject.size > 15
      errors.add(:mail_subject, "は16文字以上入力できません")
    end

    if ([U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) && self.summary.size > 171
      errors.add(:summary, "は172文字以上入力できません")
    end

    if ([COMMONS_ID, U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) && self.type_update.blank?
      errors.add(:type_update, "を選択して下さい")
    end

    if ([COMMONS_ID, U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) &&
       edition_mng.blank? && self.issue.type_update != NEW_STATUS
      errors.add(:type_update, "の「新規」を選択して下さい")
    end

    if ([COMMONS_ID, U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) && self.delivered_area.blank?
      errors.add(:delivered_area, "を選択して下さい")
    end

    if ([COMMONS_ID, U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) &&
        self.type_update == "3" && self.description_cancel.blank?
      errors.add(:description_cancel, "を入力して下さい")
    end

    if ([COMMONS_ID, U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) && self.published_at.blank?
      errors.add(:published_at, "を入力して下さい")
    end

    # トラッカーID の種別がイベント・お知らせ時のみ
    # 配信要求時にカスタムフィールドの情報識別区分 の有無のバリデーションを行う
    if (DST_LIST['general_info_ids'].include?(self.issue.tracker_id)) && [COMMONS_ID].include?(self.delivery_place_id) &&
        self.issue.disaster_info_type.blank?
      errors.add(:disaster_info_type, "を入力して下さい")
    end
    
    if ((DST_LIST['general_info_ids'].include?(self.issue.tracker_id)) || (DST_LIST['events_ids'].include?(self.issue.tracker_id))) && 
        [COMMONS_ID].include?(self.delivery_place_id) &&
        self.issue.description.blank?
      errors.add(:description, "を入力して下さい")
    end
    
    # 公開開始日時未設定の場合に、現在時刻を設定。
    if ([SMTP_0_ID, SMTP_1_ID, SMTP_2_ID, SMTP_3_ID, SMTP_AUTH_ID, TWITTER_ID, FACEBOOK_ID, ATOM_ID].include?(self.delivery_place_id)) && self.opened_at.blank?
		self.opened_at = Time.now
    end
  end
end

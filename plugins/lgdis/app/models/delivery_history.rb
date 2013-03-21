# encoding: utf-8
class DeliveryHistory < ActiveRecord::Base
  unloadable

  belongs_to :issue
  belongs_to :request_user, :class_name => "User", :foreign_key => :request_user_id
  belongs_to :respond_user, :class_name => "User", :foreign_key => :respond_user_id

  attr_accessible :issue_id, :project_id, :delivery_place_id, :status, :process_date,
                  :mail_subject, :summary, :type_update, :description_cancel, :published_at,
                  :delivered_area, :opened_at, :closed_at, :request_user_id, :respond_user_id

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
        :closed_at         => issue[:closed_at])
      x.save
      deliver_histories << x
    end
    return deliver_histories
  end

  private

  # コントロールプレーン部バリデーション処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def for_commons
    if ([SMTP_0_ID, SMTP_1_ID, SMTP_2_ID, SMTP_3_ID, SMTP_AUTH_ID, ATOM_ID,
         U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) && self.mail_subject.blank?
      errors.add(:mail_subject, "を入力して下さい")
    end

    # Redmine 本体のsummary と名前競合の為名称変更
    if ([SMTP_AUTH_ID, TWITTER_ID, FACEBOOK_ID, ATOM_ID,
         U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) && self.summary.blank?
      errors.add(:plugin_summary, "を入力して下さい")
    end

    # Redmine 本体のsummary と名前競合の為名称変更
    if ([TWITTER_ID, ATOM_ID].include?(self.delivery_place_id)) && self.summary.size >= (142 - DST_LIST['disaster_portal_url'].size)
      errors.add(:plugin_summary, "は#{142 - DST_LIST['disaster_portal_url'].size}文字以上入力できません")
    end

    if ([U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) && self.mail_subject.size > 15
      errors.add(:mail_subject, "は16文字以上入力できません")
    end

    # Redmine 本体のsummary と名前競合の為名称変更
    if ([U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) && self.summary.size > 171
      errors.add(:plugin_summary, "は172文字以上入力できません")
    end

    if ([COMMONS_ID, U_MAIL_DCM_ID, U_MAIL_SB_ID, U_MAIL_AU_ID].include?(self.delivery_place_id)) && self.type_update.blank?
      errors.add(:type_update, "を選択して下さい")
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
        self.issue.name_in_custom_field_value(DST_LIST['custom_field_delivery']['info_classification']).blank?
      errors.add(:cf_classification, "を入力して下さい")
    end
  end
end

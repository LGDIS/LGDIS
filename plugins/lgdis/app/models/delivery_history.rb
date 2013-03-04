# encoding: utf-8
class DeliveryHistory < ActiveRecord::Base
  unloadable

  belongs_to :issue

  attr_accessible :issue_id, :project_id, :delivery_place_id, :request_user, :respond_user, :status, :process_date,
                  :mail_subject, :summary, :type_update, :description_cancel, :published_date, :published_hm,
                  :delivered_area, :opened_date, :opened_hm, :closed_date, :closed_hm

#  validate :for_commons

  acts_as_datetime_separable :published_at, :opened_at, :closed_at

  validate :for_commons

  def self.create_for_history(issue, ary)
    deliver_histories = []
    ary.each do |e|
      x = self.new(
        :issue_id          => issue[:id],
        :project_id        => issue[:project_id],
        :delivery_place_id => e.to_i,
        :request_user      => User.current.login,
        :status            => 'request',
        :mail_subject      => issue[:mail_subject],
        :summary           => issue[:summary],
        :type_update       => issue[:type_update],
        :description_cancel=> issue[:description_cancel],
        :delivered_area    => issue[:delivered_area],
        :published_date    => issue.published_date,
        :published_hm      => issue.published_hm,
        :opened_date       => issue.opened_date,
        :opened_hm         => issue.opened_hm,
        :closed_date       => issue.closed_date,
        :closed_hm         => issue.closed_hm)
      x.save
      deliver_histories << x
    end
    return deliver_histories
  end

  private

  def for_commons
    if (self.delivery_place_id == 2  || self.delivery_place_id == 3  ||
        self.delivery_place_id == 4  || self.delivery_place_id == 5  ||
        self.delivery_place_id == 6  || self.delivery_place_id == 10 ||
        self.delivery_place_id == 11 || self.delivery_place_id == 12 ||
        self.delivery_place_id == 9) && self.mail_subject.blank?
      errors.add(:mail_subject, "を入力して下さい")
    end

    if (self.delivery_place_id == 9  ||
        self.delivery_place_id == 6  || self.delivery_place_id == 7  ||
        self.delivery_place_id == 8  || self.delivery_place_id == 10 ||
        self.delivery_place_id == 11 || self.delivery_place_id == 12 ) && self.summary.blank?
      errors.add(:summary, "を入力して下さい")
    end

    if (self.delivery_place_id == 7 || self.delivery_place_id == 9) && self.summary.size >= 142
      errors.add(:mail_subject, "は142文字以上入力できません")
    end

    if (self.delivery_place_id == 10 || self.delivery_place_id == 11 ||
        self.delivery_place_id == 12) && self.mail_subject.size > 15
      errors.add(:mail_subject, "は16文字以上入力できません")
    end

    if (self.delivery_place_id == 10 || self.delivery_place_id == 11 ||
        self.delivery_place_id == 12) && self.summary.size > 171
      errors.add(:mail_subject, "は172文字以上入力できません")
    end

    if (self.delivery_place_id == 1  || self.delivery_place_id == 10 ||
        self.delivery_place_id == 11 || self.delivery_place_id == 12) &&
        self.type_update.blank?
      errors.add(:type_update, "を選択して下さい")
    end

    if (self.delivery_place_id == 1  || self.delivery_place_id == 10 ||
        self.delivery_place_id == 11 || self.delivery_place_id == 12) &&
        self.delivered_area.blank?
      errors.add(:delivered_area, "を選択して下さい")
    end

    if (self.delivery_place_id == 1  || self.delivery_place_id == 10 ||
        self.delivery_place_id == 11 || self.delivery_place_id == 12) &&
        self.type_update == "3"      && self.description_cancel.blank?
      errors.add(:description_cancel, "を入力して下さい")
    end
  end
end

# encoding: utf-8
class DeliveryHistory < ActiveRecord::Base
  unloadable

  belongs_to :issue

  attr_accessible :issue_id, :project_id, :delivery_place_id, :request_user, :respond_user, :status, :process_date,
                  :mail_subject, :summary, :type_update, :description_cancel, :published_date, :published_hm,
                  :delivered_area, :opened_date, :opened_hm, :closed_date, :closed_hm

#  validate :for_commons

  acts_as_datetime_separable :published_at, :opened_at, :closed_at

  def self.create_for_history(issue, ary)
    ary.each do |e|
      self.create!(
        :issue_id          => issue[:id],
        :project_id        => issue[:project_id],
        :delivery_place_id => e.to_i,
        :request_user      => User.current.login,
        :status            => 'request',
        :process_date      => Time.now,
        :mail_subject      => issue[:mail_subject],
        :summary           => issue[:summary],
        :type_update       => issue[:type_update],
        :description_cancel=> issue[:description_cancel],
        :delivered_area    => issue[:delivered_area],
        :published_date    => issue[:published_date],
        :published_hm      => issue[:published_hm],
        :opened_date       => issue[:opened_date],
        :opened_hm         => issue[:opened_hm],
        :closed_date       => issue[:closed_date],
        :closed_hm         => issue[:closed_hm])
    end
  end

  private

  def for_commons
    if self.mail_subject.blank?
      errors.add(:mail_subject, "は必須項目です")
    end

    if self.delivery_place_id == 1 && mail_subject.blank?
      errors.add(:mail_subject, "は必須項目です")
    end
  end
end

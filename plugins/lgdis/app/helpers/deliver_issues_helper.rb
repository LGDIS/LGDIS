# encoding: utf-8
module DeliverIssuesHelper
  include ApplicationHelper

  # 管理者権限確認処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def check_admin(issue)
    return false if issue.blank?
    User.current.roles_for_project(issue.project).each do |r|
      return true if DST_LIST['dst_admin_id'].include?(r.id)
    end
    return false
  end
end

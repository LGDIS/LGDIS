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
  
  # 配信対象地域の画面表示部生成
  # ==== Args
  # ==== Return
  # 画面表示部
  # ==== Raise
  def format_delivered_area
    issue_area = @issue.delivered_area.split(',')
    delivered = []
    issue_area.each do |i_area|
      issue_i = Issue.new
      delivered << issue_i.get_area_name(i_area)
    end
    delivered_areas = ""
    delivered.each do |d_area|
      delivered_areas << d_area + "<br>"
    end
    
    return delivered_areas
  end
      
end

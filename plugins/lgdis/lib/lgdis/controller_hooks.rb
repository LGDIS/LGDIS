# -*- coding:utf-8 -*-
module Lgdis
  class ControllerHooks < Redmine::Hook::ViewListener

    AUTO_FLAG = {"1" => true}.freeze

    # controller_issues_new_after_saveホック処理
    # ==== Args
    # _context_ :: コンテキスト
    # ==== Return
    # ==== Raise
    def controller_issues_new_after_save(context={})
      param_issue = context[:params][:issue]
      # TODO
      # params に関してはparse と調整済
      create_project(context) if AUTO_FLAG[param_issue[:auto_launch]]

      # TODO
      # params に関してはparse と調整済
      deliver_issue(context) if AUTO_FLAG[param_issue[:auto_send]]
    end

    def view_account_login_bottom(context={})
      context[:controller].send(:render_to_string, {:partial => "account/view_account_login_bottom", :locals => context})
    end

    private

    # プロジェクト自動作成処理
    # ==== Args
    # _context_ :: コンテキスト
    # ==== Return
    # ==== Raise
    def create_project(context={})
      issue = context[:issue]
      new_project = Project.new
      # プロジェクト名
      new_project.name = new_project_name(issue)
      # プロジェクト識別子は、自動採番
      new_project.save!
    end

    # プロジェクト名を生成
    # ==== Args
    # _issue_ :: チケット情報
    # ==== Return
    # 生成したプロジェクト名
    # ==== Raise
    def new_project_name(issue)
      prj_name = ""
      # 発表時刻 + 標題
      prj_name += format_time(issue.xml_head_reportdatetime) if issue.xml_head_reportdatetime
      prj_name += " " if prj_name.present?
      prj_name += issue.xml_head_title.to_s
      # ブランクの場合は、チケット作成日時を暫定的に設定
      prj_name = format_time(issue.created_on) if prj_name.blank?
      return prj_name
    end

    # 自動配信処理
    # ==== Args
    # _context_ :: コンテキスト
    # ==== Return
    # ==== Raise
    def deliver_issue(context={})
      issue = context[:issue]
      raise "配備番号が未設定です" if (auto_target = context[:params][:issue][:auto_target]).blank?

      # TODO
      # redis が起動されている必要がある
      (DST_LIST['auto_destination'][auto_target.to_i] || {}).each do |destination|
        deliveryhistory = DeliveryHistory.create!(
                            :issue_id          => issue.id,
                            :project_id        => issue.project_id,
                            :delivery_place_id => destination['id'],
                            :request_user      => User.current.login,
                            :status            => 'request',
                            :process_date      => Time.now)
        issue.deliver(deliveryhistory, 'runtime')
      end
    end
  end
end


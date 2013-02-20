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
    def deliver_issue(context)
      # TODO
      # *号配備番号がパーサより送られてくる為
      # 紐付くメーリングリストに自動配信する

      issue = context[:issue]

      # TODO
      # parser より外部配信先の配列を取得予定
      # destination_ids = issue['destination_ids']
      # 現在は仮でTwitter を設定
      destination_ids = [4]
      # 通信試験モード判定
      test_flag = DST_LIST['test_prj'][issue.project_id]

      # TODO
      # redis が起動されている必要がある
      unless destination_ids.blank?
        destination_ids.each do |id|
          str = "issue." + DST_LIST['create_msg_msd'][id]
          # 配信先に合わせ配信内容作成処理
          summary = eval(str)

          # Twitter, Facebook, の本文へ適宜URL, 災害訓練モード設定
          check_ary = [DST_LIST['twitter']['target_num'],
                       DST_LIST['facebook']['target_num']]
          if check_ary.include?(id)
            summary = issue.add_url_and_training(summary, id)
          end

          Resque.enqueue(eval(DST_LIST['delivery_job_map'][id]), summary, test_flag)
          # 自動配信の履歴を登録
          DeliveryHistory.new(
                              :issue_id          => issue.id,
                              :project_id        => issue.project_id,
                              :delivery_place_id => id,
                              :request_user      => User.current.login,
                              :status            => 'request',
                              :process_date      => Time.now)

          # アーカイブの為、チケットに登録
          msg = summary['message'].blank? ? summary : summary['message']
          journal = issue.init_journal(User.current, msg)

          unless issue.save
            # TODO
            # log 出力内容
            # Rails.logger.error
          end
        end
      end
    end
  end
end


# -*- coding:utf-8 -*-
module Lgdis
  class ControllerHooks < Redmine::Hook::ViewListener

    AUTO_FLAG = {"1" => true}.freeze
    TRAINING_MESSAGE = "【災害訓練】" + "\n"
    PORTAL_URL = "… " + DST_LIST['disaster_portal_url']
    HASH_TAG = " " + DST_LIST['hashtag']

    # controller_issues_new_before_saveホック処理
    # ==== Args
    # _context_ :: コンテキスト
    # ==== Return
    # ==== Raise
    def controller_issues_new_before_save(context={})
      # 自動配信時のみ、141文字(Twitter のMAXついーとから
      # 災害ポータルのURL 文字数を引いた文字数を登録する
      issue = context[:issue]
      if AUTO_FLAG[context[:params][:issue][:auto_send]]
        send_target = context[:params][:issue][:send_target]
        project_id = context[:params][:issue][:project_id].to_s[-1, 1]
        urgent_mail = DST_LIST['delivery_place_group_urgent_mail'].map{|o| o["id"]}
        issue.opened_at = Time.now
        (DST_LIST['auto_destination'][send_target.to_i] || {}).each do |auto|
          if urgent_mail.include?(auto['id'])
            context[:issue][:mail_subject] = context[:issue][:mail_subject].slice(0, 15)
            slice_count = 171
            summary = issue.add_url_and_training(issue.summary, auto['id'], project_id.to_i)
            if summary.size > slice_count
              slice_count = slice_count - (summary.size + summary.count("\n") - issue.summary.size)
              issue.summary = issue.summary.slice(0, slice_count) + "…" 
            end
            break
          elsif auto['id'].to_s == "7"
            # httpsの場合、URLを除いたtwitterへの登録文字数は117文字だが、3点リーダと空白を除いた115文字を起点とする。
            slice_count = 115
            slice_count = slice_count - HASH_TAG.size
            summary = issue.add_url_and_training(issue.summary, auto['id'], project_id.to_i) 
            if summary.size > slice_count
              slice_count = slice_count - (summary.size - issue.summary.size)
              issue.summary = issue.summary.slice(0, slice_count) + PORTAL_URL + HASH_TAG
            else
              issue.summary = issue.summary + PORTAL_URL + HASH_TAG
            end
            break
          end
        end
     end
    end

    # controller_issues_new_after_saveホック処理
    # ==== Args
    # _context_ :: コンテキスト
    # ==== Return
    # ==== Raise
    def controller_issues_new_after_save(context={})
      param_issue = context[:params][:issue]
      # params に関してはparse と調整済
      create_project(context) if AUTO_FLAG[param_issue[:auto_launch]] && auto_launchable?

      # params に関してはparse と調整済
      deliver_issue(context) if AUTO_FLAG[param_issue[:auto_send]]
    end

    private

    # プロジェクト自動作成判定処理
    # ==== Args
    # ==== Return
    # 判定結果（true: 可、false: 不可）
    # ==== Raise
    def auto_launchable?
      raise "プラグイン設定[プロジェクト自動作成における猶予期間[日]]が存在しません。" if !(Setting.plugin_lgdis.present? && Setting.plugin_lgdis[:term_auto_launch_project])
      raise "プラグイン設定[プロジェクト自動作成における猶予期間[日]]が不正です。" if !(Setting.plugin_lgdis[:term_auto_launch_project].to_s =~ /\d+/)
      return true unless last_auto_launched_prj = Project.where(auto_launched: true).order("created_on desc").first
      return last_auto_launched_prj.created_on.to_date + Setting.plugin_lgdis[:term_auto_launch_project].to_i.days <= Date.today
    end

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
      # 自動作成フラグ
      new_project.auto_launched = true
      # プロジェクト識別子は、自動採番
      new_project.save!
      # 作成したプロジェクトにチケットをコピー
      # issue.copy(project: new_project).save!
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
      auto_target = context[:params][:issue][:send_target]
      raise "配備番号が未設定です" if auto_target.blank?

      return if DST_LIST['auto_destination_out'].include?(issue.tracker_id)
      # 自動配信の場合に二重配信を防ぐ
      return if DeliveryHistory.joins("INNER JOIN issues ON delivery_histories.issue_id = issues.id").where(:project_id => issue.project_id).where(:summary => issue.summary).where("issues.xml_head_eventid = (?)", issue.xml_head_eventid).exists?

      place_id_ary = []
      (DST_LIST['auto_destination'][auto_target.to_i] || {}).each do |destination|
         place_id_ary.push destination['id']
      end

      deliver_historires = DeliveryHistory.create_for_history(issue, place_id_ary)
      (deliver_historires || {}).each do |d_h|
        issue.deliver(d_h, 'reserve')
      end
    end
  end
end


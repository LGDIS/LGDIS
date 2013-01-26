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
      # 標題 + 発表時刻
      prj_name += issue.xml_head_title.to_s
      prj_name += " " if prj_name.present?
      prj_name += format_time(issue.xml_head_reportdatetime) if issue.xml_head_reportdatetime
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
      # 仮実装
      # 
      # TODO
      # 通信試験モード、災害訓練モードに関しては
      # プロジェクトのID を参照
      # 定義はyaml ファイルに記載のこと
      # test_flag = context[:params][:test]
      # disaster_training_flag = context[:params][:training]
      # destination_ids = context[:params][:issue][:destination_id]
      test_flag = false
      disaster_training_flag = true
      destination_ids = [4]
      issue = context[:issue]
      # TODO
      # 配信先に紐付く、配信内容未決
      # TODO
      # redis が起動されている必要がある
      unless destination_ids.blank?
        destination_ids.each do |id|
          str = DST_LIST['create_msg_msd'][id] + \
                "(issue,  disaster_training_flag)"
          content_delivery = eval(str)

          Resque.enqueue(eval(DST_LIST['delivery_job_map'][id]),
                         content_delivery,
                         test_flag)
        end
      end
    end

    # 公共情報コモンズ用 配信メッセージ作成処理
    # ==== Args
    # _issue_ :: チケット情報
    # _disaster_training_flag_ :: 災害訓練フラグ
    # ==== Return
    # ==== Raise
    def create_commons_msg(issue, disaster_training_flag)
      # TODO
      # 配信内容未決
    end

    # 自治体職員用 配信メッセージ作成処理
    # ==== Args
    # _issue_ :: チケット情報
    # _disaster_training_flag_ :: 災害訓練フラグ
    # ==== Return
    # チケットのデータを成形した、メーリングリスト、標題、本文 のHash データ
    # ==== Raise
    def create_smtp_msg(issue, disaster_training_flag)
      # TODO
      # 配信内容未決
      content_delivery =
        {'mailing_list_name' => DST_LIST['mailing_list']['local_government_officer_mail'],
         'title'   => issue.subject,
         'message' => create_disaster_training_str(issue, disaster_training_flag)}
    end

    # SNS(Twitter, Facebook)用 配信メッセージ作成処理
    # ==== Args
    # _issue_ :: チケット情報
    # _disaster_training_flag_ :: 災害訓練フラグ
    # ==== Return
    # チケットの説明 部分の文字列
    # ==== Raise
    def create_sns_msg(issue, disaster_training_flag)
      # TODO
      # 配信内容未決
      create_disaster_training_str(issue, disaster_training_flag)
    end

    # 共通配信メッセージ作成処理
    # ==== Args
    # _issue_ :: チケット情報
    # _disaster_training_flag_ :: 災害訓練フラグ
    # ==== Return
    # チケットの説明 部分の文字列（災害訓練付加）
    # ==== Raise
    def create_disaster_training_str(issue, flg)
      # TODO
      # 配信内容未決
      str = flg.blank? ? '' : '【災害訓練】'
      str + issue.description
    end
  end
end


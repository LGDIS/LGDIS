# encoding: utf-8
module Lgdis
  class ControllerHooks < Redmine::Hook::ViewListener
    DELIVERY_JOB_MAP = {# 1 => ::CommonsRequestJob,
                        # 2 => ::MachicomiRequestJob,
                         3 => ::TwitterRequestJob,
                         4 => ::FacebookRequestJob
                       }.freeze

    # controller_issues_new_after_saveホック処理
    # ==== Args
    # _context_ :: コンテキスト
    # ==== Return
    # ==== Raise
    def controller_issues_new_after_save(context={})
      # TODO
      # parser 部に依頼
      create_project(context) if context[:params][:automatic_create_project_flag]
      auto_flag = context[:params][:automatic_delivery_flag]
      # test_flag = context[:params][:com_test_flag]
      # destination_ids = context[:params][:issue][:destination_id]

      # TODO
      # 仮実装
      #auto_flag = true
      test_flag = true
      destination_ids = [3,4]

      if auto_flag
        # TODO
        # 配信先に紐付く、配信内容が決まっていない
        # issue のどの項目(連結して?)を配信するか
        # 
        unless destination_ids.blank?
          destination_ids.each do |id|
            Resque.enqueue(DELIVERY_JOB_MAP[id], "test_comment", test_flag)
          end
        end
      end
    end
    
    private
    
    # プロジェクト自動作成処理
    # ==== Args
    # _context_ :: コンテキスト
    # ==== Return
    # ==== Raise
    def create_project(context={})
      # プロジェクトを作成
      issue = context[:issue]
      created_on_str = issue.created_on.strftime("%Y%m%d%H%M%S")
      # TODO:作成情報が未決
      new_project = Project.create!(name: "#{created_on_str} #{issue.subject}",
          identifier: "prj-#{created_on_str}",
          description: "#{issue.description}",
          #tracker_ids: {},
          #homepage: "",
          )
      
      # 作成したプロジェクトにチケットをコピー
      issue.move_to_project(new_project, nil, copy: true)
    end
  end
end


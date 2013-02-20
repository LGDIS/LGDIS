# -*- coding:utf-8 -*-
class DeliverIssuesController < ApplicationController
  unloadable

  before_filter :find_project #, :authorize

  def index
    issue_id = params['issue'].to_i
    delivery_history_id = params['delivery_history_id'].to_i
    @issue = Issue.find_by_id issue_id
    @delivery_history = DeliveryHistory.find_by_id delivery_history_id
    # 配信内容作成処理
    contents = create_summary(@issue, @delivery_history)

    @summary = contents.instance_of?(Hash) ? contents['message'] : contents
  end

  # 外部配信要求処理(手動配信)
  # 外部配信要求受付け処理を行います
  # ==== Args
  # ==== Return
  # ==== Raise
  def request_delivery
    issue_id    = params[:issue_id]
    user_name   = params[:current_user]
    ext_out_ary = params[:ext_out_target]

    issue = Issue.find_by_id issue_id.to_i

    unless ext_out_ary.blank?
      ext_out_ary.each do |e|
        histry_obj = DeliveryHistory.new(
                       :issue_id          => issue_id,
                       :project_id        => User.current.id,
                       :delivery_place_id => e.to_i,
                       :request_user      => user_name,
                       :status            => 'request',
                       :process_date      => Time.now)

        if histry_obj.save && issue.update_attributes(params[:issue])
          flash[:notice] = l(:notice_delivery_request_successful)
        else
          flash[:notice] = l(:notice_delivery_request_failed)
        end
      end
    else
      flash[:notice] = l(:notice_delivery_unselected)
    end

    respond_to do |format|
      format.html do
        redirect_back_or_default({:controller => 'issues',
                                  :action     => 'show',
                                  :id         => issue_id.to_i})
      end
    end
  end

  # 外部配信処理(手動配信)
  # 外部配信する配信内容の作成処理、
  # 災害訓練、通信テストの判断処理、
  # 外部配信実行処理を行います
  # ==== Args
  # ==== Return
  # ==== Raise
  def allow_delivery
    begin
      id       = params[:id].to_i
      status   = params[:allow].blank? ? 'reject' : 'runtime'
      issue_id = params[:issue_id].to_i

      delivery_history = DeliveryHistory.find_by_id(id)
      issue = Issue.find_by_id(issue_id)

      return if delivery_history.blank? || issue.blank?

      # 配信内容作成処理
      summary = create_summary(issue, delivery_history)

      # 通信試験モード判定
      test_flag = DST_LIST['test_prj'][issue.project_id]

      if status != 'reject'
        Resque.enqueue(eval(DST_LIST['delivery_job_map'][delivery_history.delivery_place_id]), summary, test_flag, issue, delivery_history)

        # アーカイブの為、チケットに登録
        msg = summary['message'].blank? ? summary : summary['message']
        journal = issue.init_journal(User.current, msg)
        unless issue.save
         # TODO
         # log 出力内容
         # Rails.logger.error
        end

        flash[:notice] = l(:notice_delivery_successful)
      else
        flash[:notice] = l(:notice_delivery_request_reject)
      end
    rescue
      # TODO
      # log 出力
      p $!
      status = 'failed'
      flash[:notice] = l(:notice_delivery_failed)
    ensure
      delivery_history.update_attribute(:status, status)
      respond_to do |format|
        format.html do
          redirect_back_or_default({:controller => 'issues',
                                    :action     => 'show',
                                    :id         => issue_id.to_i})
        end
      end
    end
  end

  private

  # プロジェクト情報取得
  # ==== Args
  # ==== Return
  # ==== Raise
  def find_project
    @project = Project.find(params[:project_id])
  end

  # 配信先判定、配信内容振り分け処理
  # 災害訓練の判断処理
  # ==== Args
  # _issue_ :: チケット情報
  # _delivery_history_ :: 配信情報
  # ==== Return
  # _summary_ :: 配信内容
  # ==== Raise
  def create_summary(issue, delivery_history)
    exit_out_id = delivery_history.delivery_place_id
    str = "issue." + DST_LIST['create_msg_msd'][exit_out_id]

    # TODO
    # Atom

    # 配信先に合わせ配信内容作成処理
    summary = eval(str)

    # Twitter, Facebook, の本文へ適宜URL, 災害訓練モード設定
    check_ary = [DST_LIST['twitter']['target_num'],
                 DST_LIST['facebook']['target_num']]
    if check_ary.include?(exit_out_id)
      summary = issue.add_url_and_training(summary, exit_out_id)
    end

    return summary
  end
end

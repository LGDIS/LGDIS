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
    contents = @issue.create_summary(@delivery_history.delivery_place_id)

    @summary = contents.instance_of?(Hash) ? contents['message'] : contents
  end

  class ParamsException < StandardError; end

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
    raise ParamsException, l(:notice_delivery_unselected) if ext_out_ary.blank?

    ActiveRecord::Base.transaction do
      issue.update_attributes!(params[:issue])
      DeliveryHistory.create_for_history(issue, ext_out_ary)
      flash[:notice] = l(:notice_delivery_request_successful)
    end
  rescue ActiveRecord::RecordInvalid
    flash[:error] = l(:notice_delivery_request_failed)
  rescue ParamsException => e
    flash[:error] = e.message
  ensure
    redirect_back_or_default({:controller => 'issues',
                              :action     => 'show',
                              :id         => issue_id.to_i})
  end

  # 外部配信処理(手動配信)
  # 外部配信する配信内容の作成処理、
  # 災害訓練、通信テストの判断処理、
  # 外部配信実行処理を行います
  # ==== Args
  # ==== Return
  # ==== Raise
  def allow_delivery
    id       = params[:id].to_i
    status_to   = params[:allow].blank? ? 'reject' : 'runtime'
    issue_id = params[:issue_id].to_i

    delivery_history = DeliveryHistory.find_by_id(id)
    issue = Issue.find_by_id(issue_id)

    return if delivery_history.blank? || issue.blank?

    case issue.deliver(delivery_history, status_to).status
    when 'reject'
      flash[:notice] = l(:notice_delivery_request_reject)
    when 'failed'
      flash[:error] = l(:notice_delivery_failed)
    else
      flash[:notice] = l(:notice_delivery_successful)
    end
    respond_to do |format|
      format.html do
        redirect_back_or_default({:controller => 'issues',
                                  :action     => 'show',
                                  :id         => issue_id.to_i})
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

end

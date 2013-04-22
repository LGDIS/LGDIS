# -*- coding:utf-8 -*-
class DeliverIssuesController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id #, :authorize

  def index
    issue_id = params['issue'].to_i
    delivery_history_id = params['delivery_history_id'].to_i
    @issue = Issue.find_by_id issue_id
    @delivery_history = DeliveryHistory.find_by_id delivery_history_id
    @issue_const = Constant::hash_for_table(Issue.table_name)
    # 配信内容作成処理
    contents = @issue.create_summary(@delivery_history.delivery_place_id)

    @summary = contents.instance_of?(Hash) ? contents['message'] : @issue.summary
  end

  # 外部配信処理(手動配信)
  # 外部配信する配信内容の作成処理、
  # 災害訓練、通信テストの判断処理、
  # 外部配信実行処理を行います
  # ==== Args
  # ==== Return
  # ==== Raise
  def allow_delivery
    id        = params[:id].to_i
    status_to = params[:allow].blank? ? 'reject' : 'reserve'
    issue_id  = params[:issue_id].to_i

    delivery_history = DeliveryHistory.find_by_id(id)
    issue = Issue.find_by_id(issue_id)

    return if delivery_history.blank? || issue.blank?

    case issue.deliver(delivery_history, status_to)
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

end

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
  class RecordInvalid < StandardError; end

  # 外部配信要求処理(手動配信)
  # 外部配信要求受付け処理を行います
  # ==== Args
  # ==== Return
  # ==== Raise
  def request_delivery
    issue_id    = params[:issue_id]
    user_name   = params[:current_user]
    ext_out_ary = params[:ext_out_target]

    @issue = Issue.find_by_id issue_id.to_i
    raise ParamsException, l(:notice_delivery_unselected) if ext_out_ary.blank?

    ActiveRecord::Base.transaction do
      issue_map = params[:issue]
      # イベント・お知らせ のxml_body 部を生成
      if DST_LIST['general_info_ids'].include?(@issue.tracker_id) &&
         ext_out_ary.include?(DST_LIST['delivery_place'][1]['id'].to_s)
        issue_map.store('xml_body', @issue.create_commons_event_body)
      end

      # 情報の配信対象地域のコード値をstring に変換
      issue_map = convert_issue_map(issue_map)
      @issue.update_attributes(issue_map)
      deliver_historires =  DeliveryHistory.create_for_history(@issue, ext_out_ary)
      error_messages = error_messages_for_issues(deliver_historires)
      raise RecordInvalid, error_messages if error_messages.present?
      flash[:notice] = l(:notice_delivery_request_successful)
    end
  rescue RecordInvalid => e
    flash[:error] = e.message.gsub(/\r\n|\r|\n/, "<br />")
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
    id        = params[:id].to_i
    status_to = params[:allow].blank? ? 'reject' : 'runtime'
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

  private

  # プロジェクト情報取得
  # ==== Args
  # ==== Return
  # ==== Raise
  def find_project
    @project = Project.find(params[:project_id])
  end

  # チケット照会画面一括更新用エラーメッセージ作成処理
  # ==== Args
  # _objects_ :: 配信履歴配列
  # ==== Return
  # エラーメッセージ
  # ==== Raise
  def error_messages_for_issues(*objects)
    messages = ""
    errors   = nil
    objects.each do |object|
      errors = object.map do |o|
        o.errors.full_messages.map do |m|
          "#{l('delivery_place')}が\"#{DST_LIST['delivery_place'][o.delivery_place_id]['name']}\"の場合は、#{m}"
        end
      end.flatten
    end
    if errors.any?
      errors.each do |error|
        messages << "#{error}\n"
      end
    end
    return messages
  end

  # チケット更新情報修正処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def convert_issue_map(issue_map)
    if issue_map['delivered_area'].present?
      code_str = issue_map['delivered_area'].join(',')
      issue_map['delivered_area'] = code_str
    end
    issue_map
  end
end

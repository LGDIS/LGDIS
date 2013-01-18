# -*- coding:utf-8 -*-
class DeliverIssuesController < ApplicationController
  unloadable

  EXT_OUT_MAP = {'commons'   => 1,
                 'machicomi' => 2,
                 'twitter'   => 3,
                 'facebook'  => 4}.freeze

  EXT_OUT_MAP_JP = {'公共情報コモンズ' => 1,
                    'まちcomi'         => 2,
                    'Twitter'          => 3,
                    'Facebook'         => 4}.freeze

  def request_delivery
    issue_id    = params[:issue_id]
    user_name   = params[:current_user]
    ext_out_ary = params[:ext_out_target]

    unless ext_out_ary.blank?
      ext_out_ary.each do |e|
        histry_obj = DeliveryHistory.new(
                       :issue_id       => issue_id,
                       :delivery_place => EXT_OUT_MAP_JP.key(e.to_i),
                       :request_user   => user_name,
                       :status         => 'request',
                       :process_date   => Time.now)
        if histry_obj.save
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

  def allow_delivery
    begin
      ext_out_id = params[:ext_out_id]
      issue_id   = params[:issue_id]
      status     = params[:allow].blank? ? 'reject' : 'done'
      delivery_history = DeliveryHistory.find_by_id(ext_out_id)

      return if delivery_history.blank?

      # TODO
      # 配信内容,通信試験モードフラグを変更する必要があります
      # Resque.enqueue の第2, 3引数
      if status != 'reject'
        case EXT_OUT_MAP_JP[delivery_history.delivery_place]
        when EXT_OUT_MAP['commons']
        when EXT_OUT_MAP['machicomi']
        when EXT_OUT_MAP['twitter']
          Resque.enqueue(TwitterRequestJob, "tw_test", false)
        when EXT_OUT_MAP['facebook']
          Resque.enqueue(FacebookRequestJob, "fc_test", false)
        end
        flash[:notice] = l(:notice_delivery_successful)
      else
        flash[:notice] = l(:notice_delivery_request_reject)
      end
      delivery_history.update_attribute(:status, status)
    rescue
      # TODO
      # log 出力
      p $!
      flash[:notice] = l(:notice_delivery_failed)
    ensure
      respond_to do |format|
        format.html do
          redirect_back_or_default({:controller => 'issues',
                                    :action     => 'show',
                                    :id         => issue_id.to_i})
        end
      end
    end
  end
end

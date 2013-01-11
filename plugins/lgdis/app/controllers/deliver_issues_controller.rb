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

  def deliver_request
    issue_id    = params[:issue_id]
    user_name   = params[:current_user]
    ext_out_ary = params[:ext_out_target]

    time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    unless ext_out_ary.blank?
      ext_out_ary.each do |e|
        histry_obj = DeliveryHistory.new(
                       :issue_id       => issue_id,
                       :delivery_place => EXT_OUT_MAP_JP.key(e),
                       :request_user   => user_name,
                       :status         => 'request',
                       :process_date   => time)

        if histry_obj.save
          flash[:notice] = l(:notice_delivery_request_successful)
        else
          flash[:notice] = l(:notice_delivery_request_failed)
        end
      end
    end

    respond_to do |format|
      format.html do
        redirect_back_or_default({:controller => 'issues',
                                  :action     => 'show',
                                  :id         => issue_id.to_i})
      end
    end
  end

  def deliver_response
=begin
    ext_out = params[:ext_out_target]
    status  = params[:status]

    case e
    when EXT_OUT_MAP[:commons]
    when EXT_OUT_MAP[:machicomi]
    when EXT_OUT_MAP[:twitter]
      Resque.enqueue(TwitterRequestJob, "tw_test", false)
    when EXT_OUT_MAP[:facebook]
      Resque.enqueue(FacebookRequestJob, "fc_test", false)
    end
=end
  end
end

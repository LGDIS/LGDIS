class DeliveryProjectController < ApplicationController
  unloadable

  skip_before_filter :check_if_login_required

  # LGDSF連携用機能
  # 初期表示処理
  # ==== Args
  # ==== Return
  # ==== Raise

  def getproject
    id = DeliveryHistory.find(:first, :conditions => ["status = :status and delivery_place_id in (:delivery_place_id)", :status => "done", :delivery_place_id => params[:id] ] , :order => "updated_at DESC")
    if id.present?
      render :text => id.project_id
    else
      render :text => ""
    end
  end
end
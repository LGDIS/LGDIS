class DeliveryHistoriesController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id

  # 配信管理履歴
  # 初期表示処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def index
    @search = @project.delivery_histories.search(params[:search])
    @delivery_histories = @search.paginate(:page => params[:page], :order => 'created_at desc', :per_page => 30)
  end

end

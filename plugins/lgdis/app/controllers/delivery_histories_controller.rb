class DeliveryHistoriesController < ApplicationController
  unloadable

  before_filter :find_project

  # 配信管理履歴
  # 初期表示処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def index
    @search = DeliveryHistory.search(params[:search])
    @delivery_histories = @search.paginate(:page => params[:page], :order => 'created_at desc', :per_page => 30)
  end

  private

  # プロジェクト情報取得
  # ==== Args
  # ==== Return
  # ==== Raise
  def find_project
    unless params[:project_id].blank?
      @project = Project.find(params[:project_id])
      params[:search] = {:project_id_equals => @project.id} 
    else 
      @project = Project.find(params[:search][:project_id_equals])
    end
  end
end

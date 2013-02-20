class DeliveryHistoriesController < ApplicationController
  unloadable

  before_filter :find_project

  # 配信管理履歴
  # 初期表示処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def index
    @delivery_histories = DeliveryHistory.where(:project_id => @project.id)
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

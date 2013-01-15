# encoding: utf-8
class SheltersController < ApplicationController
  unloadable
  
  before_filter :find_project, :authorize
  before_filter :init
  
  # 共通初期処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def init
    @shelter_const = Constant::hash_for_table(Shelter.table_name)
  end
  
  # 避難所一覧検索画面
  # 初期表示処理
  # ==== Args
  # _params[:search]_ :: 画面入力された検索条件
  # ==== Return
  # ==== Raise
  def index
    @search   = Shelter.search(params[:search])
    @shelters = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
    render :action => :index
  end
  
  # 避難所登録・更新画面
  # 初期表示処理（新規登録）
  # ==== Args
  # ==== Return
  # ==== Raise
  def new
    @shelter = Shelter.new
  end
  
  # 避難所登録・更新画面
  # 初期表示処理（編集）
  # ==== Args
  # _params[:id]_ :: 避難所ID
  # ==== Return
  # ==== Raise
  def edit
    @shelter = Shelter.find(params[:id])
  end
  
  # 避難所登録・更新画面
  # 登録処理
  # ==== Args
  # _params[:shelter]_ :: 画面入力値
  # ==== Return
  # ==== Raise
  def create
    @shelter = Shelter.new()
    @shelter.assign_attributes(params[:shelter], :as => :shelter)
    @shelter.project_id = @project.id
    @shelter.disaster_code = @project.identifier
    if @shelter.save
      flash[:notice] = l(:notice_shelter_successful_create, :id => "##{@shelter.id} #{@shelter.name}")
      redirect_to :action  => :edit, :id => @shelter.id
    else
      render :action  => :new
    end
  end
  
  # 避難所登録・更新画面
  # 更新処理
  # ==== Args
  # _params[:id]_ :: 避難所ID
  # _params[:shelter]_ :: 画面入力値
  # ==== Return
  # ==== Raise
  def update
    @shelter = Shelter.find(params[:id])
    @shelter.assign_attributes(params[:shelter], :as => :shelter)
    if @shelter.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action  => :edit
    else
      render :action  => :edit
    end
  end
  
  # 避難所登録・更新画面
  # 削除処理
  # ==== Args
  # _params[:id]_ :: 避難所ID
  # ==== Return
  # ==== Raise
  def destroy
    @shelter = Shelter.find(params[:id])
    if @shelter.destroy
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to :action  => :index
  end
  
  private
  
  # プロジェクト情報取得
  # ==== Args
  # _params[:project_id]_ :: プロジェクトID
  # ==== Return
  # ==== Raise
  def find_project
    # authorize filterの前に、@project にセットする
    @project = Project.find(params[:project_id])
  end
  
end
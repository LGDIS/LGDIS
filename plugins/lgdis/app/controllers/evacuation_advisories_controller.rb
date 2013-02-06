# encoding: utf-8
class EvacuationAdvisoriesController < ApplicationController
  unloadable

#k-takami dev:     
  before_filter :find_project
#   before_filter :authorize
  before_filter :init

  # 共通初期処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def init
    @evacuation_advisory_const = Constant::hash_for_table(EvacuationAdvisory.table_name)
  end
  
  # 避難所一覧検索画面
  # 初期表示処理
  # 押下されたボタンにより処理を分岐
  # ==== Args
  # _params[:search]_ :: 検索条件
  # _params[:commit_kind]_ :: ボタン種別
  # ==== Return
  # 検索ボタンが押下された場合、検索条件を元に検索を行い結果を表示する
  # クリアボタンが押下された場合、検索条件が未指定の状態で検索を行い結果を表示する
  # 新規登録ボタンが押下された場合、避難所登録画面に遷移する
  # 更新ボタンが押下された場合、避難所情報の一括更新を行う
  # チケット登録ボタンが押下された場合、全ての避難所情報をXML化しチケットに登録する
  # 集計ボタンが押下された場合、LGDPMから避難者集計情報を取得し避難所情報に登録する
  # ==== Raise
  def index
    case params["commit_kind"]
    when "search"
      @search   = EvacuationAdvisory.search(params[:search])
      @evacuation_advisories = @search.paginate(:page => params[:page], :per_page => 30).order("disaster_code ASC")
      render :action => :index
    when "new"
      redirect_to :action => :new
    when "clear"
      @search   = EvacuationAdvisory.search
      @evacuation_advisories = @search.paginate(:page => params[:page], :per_page => 30).order("disaster_code ASC")
      render :action => :index
    when "bulk_update"
      bulk_update
    when "ticket"
      ticket
    when "summary"
      summary
    else
      @search   = EvacuationAdvisory.search(params[:search])
      @evacuation_advisories = @search.paginate(:page => params[:page], :per_page => 30).order("disaster_code ASC")
      render :action => :index
    end
  end
  
  # 避難所一覧検索画面
  # ステータス更新処理
  # ==== Args
  # _params[:evacuation_advisories]_ :: 避難所更新情報配列
  # ==== Return
  # ==== Raise
  def bulk_update
    if params[:evacuation_advisories].present?
      evacuation_advisory_id = params[:evacuation_advisories].keys
      @search    = EvacuationAdvisory.search(:id_in => evacuation_advisory_id)
      @evacuation_advisories  = @search.paginate(:page => params[:page], :per_page => 30).order("disaster_code ASC")
      ActiveRecord::Base.transaction do
        @evacuation_advisories.each do |evacuation_advisory|
          evacuation_advisory.sort_criteria = params[:evacuation_advisories]["#{evacuation_advisory.id}"]["sort_criteria"]
          evacuation_advisory.issued_at  = params[:evacuation_advisories]["#{evacuation_advisory.id}"]["issued_at"]
#           evacuation_advisory.issued_hm    = params[:evacuation_advisories]["#{evacuation_advisory.id}"]["issued_hm"]
          evacuation_advisory.lifted_at  = params[:evacuation_advisories]["#{evacuation_advisory.id}"]["lifted_at"]
#           evacuation_advisory.lifted_hm    = params[:evacuation_advisories]["#{evacuation_advisory.id}"]["lifted_hm"]
#           evacuation_advisory.status       = params[:evacuation_advisories]["#{evacuation_advisory.id}"]["status"]
          evacuation_advisory.save
        end
      end
    else
      @search   = EvacuationAdvisory.search(params[:search])
      @evacuation_advisories = @search.paginate(:page => params[:page], :per_page => 30).order("disaster_code ASC")
    end
    
    render :action => :index
  end
  
  # 避難所一覧検索画面
  # チケット登録処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def ticket
    # 避難所情報が存在しない場合、処理しない
    if EvacuationAdvisory.where(:project_id => @project.id).present?
      ActiveRecord::Base.transaction do
        ### Applic用チケット登録
        EvacuationAdvisory.create_applic_issue(@project)
        ### 公共コモンズ用チケット登録
        EvacuationAdvisory.create_commons_issue(@project)
      end
      flash[:notice] = "チケットを登録しました。"
    else
      flash[:error] = "避難所情報が存在しません。"
    end
    redirect_to :action => :index
  end
  
  # 避難所一覧検索画面
  # 避難者情報サマリー処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def summary
    redirect_to :action => :index
  end
  
  # 避難所登録・更新画面
  # 初期表示処理（新規登録）
  # ==== Args
  # ==== Return
  # ==== Raise
  def new
    @evacuation_advisory = EvacuationAdvisory.new
  end
  
  # 避難所登録・更新画面
  # 初期表示処理（編集）
  # ==== Args
  # ==== Return
  # ==== Raise
  def edit
    @evacuation_advisory = EvacuationAdvisory.find(params[:id])
  end
  
  # 避難所登録・更新画面
  # 登録処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def create
    @evacuation_advisory = EvacuationAdvisory.new()
    @evacuation_advisory.assign_attributes(params[:evacuation_advisory], :as => :evacuation_advisory)
    @evacuation_advisory.project_id = @project.id
    @evacuation_advisory.disaster_code = @project.identifier
    if @evacuation_advisory.save
      flash[:notice] = l(:notice_evacuation_advisory_successful_create, :id => "##{@evacuation_advisory.id} #{@evacuation_advisory.full_name}")
      redirect_to :action  => :edit, :id => @evacuation_advisory.id
    else
      render :action  => :new
    end
  end
  
  # 避難所登録・更新画面
  # 更新処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def update
    @evacuation_advisory = EvacuationAdvisory.find(params[:id])
    @evacuation_advisory.assign_attributes(params[:evacuation_advisory], :as => :evacuation_advisory)
    if @evacuation_advisory.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action  => :edit
    else
      render :action  => :edit
    end
  end
  
  # 避難所登録・更新画面
  # 削除処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def destroy
    @evacuation_advisory = EvacuationAdvisory.find(params[:id])
    if @evacuation_advisory.destroy
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to :action  => :index
  end
  
  private
  
  # プロジェクト情報取得
  # ==== Args
  # ==== Return
  # ==== Raise
  def find_project
    # authorize filterの前に、@project にセットする
    @project = Project.find(params[:project_id])
  end
end

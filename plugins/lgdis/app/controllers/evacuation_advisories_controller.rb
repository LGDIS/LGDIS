# encoding: utf-8
class EvacuationAdvisoriesController < ApplicationController
  unloadable
   
  before_filter :find_project, :authorize
  before_filter :init
  
  class ParamsException < StandardError; end

  # 共通初期処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def init
    @evacuation_advisory_const = Constant::hash_for_table(EvacuationAdvisory.table_name)
    @areas = Area.all
    # TODO:発令・解除地区名称（中域）の持ち方,内容について検討
    @sections = {}
  end
  
  # 避難勧告･指示一覧検索画面
  # 初期表示処理
  # 押下されたボタンにより処理を分岐
  # * 検索ボタンが押下された場合、検索条件を元に検索を行い結果を表示する
  # * クリアボタンが押下された場合、検索条件が未指定の状態で検索を行い結果を表示する
  # * 新規登録ボタンが押下された場合、避難勧告･指示登録画面に遷移する
  # * 更新ボタンが押下された場合、避難勧告･指示情報の一括更新を行う
  # * チケット登録ボタンが押下された場合、全ての避難勧告･指示情報をXML化しチケットに登録する
  # ==== Args
  # _search_ :: 検索条件
  # _commit_kind_ :: ボタン種別
  # ==== Return
  # ==== Raise
  def index
    case params["commit_kind"]
    when "search"
      @search   = EvacuationAdvisory.search(params[:search])
      @evacuation_advisories = @search.paginate(:page => params[:page], :per_page => 30).order("identifier ASC")
      render :action => :index
    when "new"
      redirect_to :action => :new
    when "clear"
      @search   = EvacuationAdvisory.search
      @evacuation_advisories = @search.paginate(:page => params[:page], :per_page => 30).order("identifier ASC")
      render :action => :index
    when "bulk_update"
      bulk_update
    when "ticket"
      ticket
    else
      @search   = EvacuationAdvisory.search(params[:search])
      @evacuation_advisories = @search.paginate(:page => params[:page], :per_page => 30).order("identifier ASC")
      render :action => :index
    end
  end
  
  # 避難勧告･指示一覧検索画面
  # ステータス更新処理
  # ==== Args
  # _evacuation_advisories_ :: 避難勧告･指示更新情報配列
  # ==== Return
  # ==== Raise
  def bulk_update
    if params[:evacuation_advisories].present?
      eva_id = params[:evacuation_advisories].keys
      @search    = EvacuationAdvisory.search(:id_in => eva_id)
      @evacuation_advisories  = @search.paginate(:page => params[:page], :per_page => 30).order("identifier ASC")
      ActiveRecord::Base.transaction do
        @evacuation_advisories.each do |eva|
          eva.assign_attributes(params[:evacuation_advisories]["#{eva.id}"])
          eva.save
        end
      end
      # エラーが存在しない場合メッセージを出力する
      flash.now[:notice] = l(:notice_successful_update) unless @evacuation_advisories.map{|ea| ea.errors.any? }.include?(true)
    else
      @search   = EvacuationAdvisory.search(params[:search])
      @evacuation_advisories = @search.paginate(:page => params[:page], :per_page => 30).order("identifier ASC")
    end
    
    render :action => :index
  end
  
  # 避難勧告･指示一覧検索画面
  # チケット登録処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def ticket
    # 避難勧告･指示情報が存在しない場合、処理しない
    if EvacuationAdvisory.limit(1).present?
      begin
        # 発令区分の遷移履歴を更新する
        @search = EvacuationAdvisory.search(params[:search])
        @evacuation_advisories = EvacuationAdvisory.paginate(:page => params[:page]).order("identifier ASC")
        sort_criteria_history = EvacuationAdvisory.update_sort_criteria_history(@evacuation_advisories)
        if @evacuation_advisories.map{|ea| ea.errors.any? }.include?(true)
          render :action => :index
          return
        end

        # チケット作成
        issues = EvacuationAdvisory.create_issues(@project, :description => sort_criteria_history)
        links = []
        issues.each do |issue|
          links << view_context.link_to("##{issue.id}", issue_path(issue), :title => issue.subject)
        end
        flash[:notice] = l(:notice_issue_successful_create, :id => links.join(","))
      rescue ParamsException
        flash[:error] = l(:error_not_exists_announcement)
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.record.errors.full_messages.join("<br>")
      end
    else
      flash[:error] = l(:error_not_exists_evacuation_advisories)
    end
    redirect_to :action => :index
  end
  
  # 避難勧告･指示登録・更新画面
  # 初期表示処理（新規登録）
  # ==== Args
  # ==== Return
  # ==== Raise
  def new
    @evacuation_advisory = EvacuationAdvisory.new
  end
  
  # 避難勧告･指示登録・更新画面
  # 初期表示処理（編集）
  # ==== Args
  # ==== Return
  # ==== Raise
  def edit
    @evacuation_advisory = EvacuationAdvisory.find(params[:id])
  end
  
  # 避難勧告･指示登録・更新画面
  # 登録処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def create
    @evacuation_advisory = EvacuationAdvisory.new()
    @evacuation_advisory.assign_attributes(params[:evacuation_advisory])

    if @evacuation_advisory.save
      flash[:notice] = l(:notice_evacuation_advisory_successful_create, :id => "##{@evacuation_advisory.id} #{@evacuation_advisory.headline}")
      redirect_to :action  => :edit, :id => @evacuation_advisory.id
    else
      render :action  => :new
    end
  end
  
  # 避難勧告･指示登録・更新画面
  # 更新処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def update
    @evacuation_advisory = EvacuationAdvisory.find(params[:id])
    @evacuation_advisory.assign_attributes(params[:evacuation_advisory])
    if @evacuation_advisory.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action  => :edit
    else
      render :action  => :edit
    end
  end
  
  # 避難勧告･指示登録・更新画面
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

# encoding: utf-8
class EvacuationAdvisoriesController < ApplicationController
  unloadable
   
  before_filter :find_project_by_project_id, :authorize
  before_filter :init
  
  class ParamsException < StandardError; end
  class RequiredException < StandardError; end

  # 共通初期処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def init
    # @edition_management = EditionManagement.find_by_project_id_and_tracker_id_and_delivery_place_id(@project.id, 1, 1)
    @edition_management = EditionManagement.find(:first, :conditions => ["project_id = ? and tracker_id = ? and delivery_place_id = ? and status != ?", @project.id, 1, 1, 3])
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
      @search   = EvacuationAdvisory.mode_in(@project).search(params[:search])
      @evacuation_advisories = @search.paginate(:page => params[:page], :per_page => 30).order("identifier ASC")
      render :action => :index
    when "new"
      redirect_to :action => :new
    when "clear"
      @search   = EvacuationAdvisory.mode_in(@project).search
      @evacuation_advisories = @search.paginate(:page => params[:page], :per_page => 30).order("identifier ASC")
      render :action => :index
    when "bulk_update"
      bulk_update
    when "ticket"
      ticket
    else
      @search   = EvacuationAdvisory.mode_in(@project).search(params[:search])
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
      @search    = EvacuationAdvisory.mode_in(@project).search(:id_in => eva_id)
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
      @search   = EvacuationAdvisory.mode_in(@project).search(params[:search])
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
    if EvacuationAdvisory.mode_in(@project).limit(1).present?
      # 避難勧告一覧画面で入力情報が更新されてるか確認
      evacuation_advisories_update_status = true
      eva_id = params[:evacuation_advisories].keys
      @search   = EvacuationAdvisory.mode_in(@project).search(:id_in => eva_id)
      @evacuation_advisories = @search.paginate(:page => params[:page], :per_page => 30).order("identifier ASC")
      @evacuation_advisories.each do |eva|
        # 区分の確認
        unless params[:evacuation_advisories]["#{eva.id}"][:current_sort_criteria] == eva[:current_sort_criteria]
          evacuation_advisories_update_status = false
        end
        # 発令日時の確認
        params_issued_at = nil
        eva_issued_at = nil
        unless params[:evacuation_advisories]["#{eva.id}"][:issued_at].blank?
          params_issued_at = Time.parse(params[:evacuation_advisories]["#{eva.id}"][:issued_at]).strftime("%Y-%m-%d %H:%M:%S")
        end
        unless eva[:issued_at].blank?
          eva_issued_at = eva[:issued_at].strftime("%Y-%m-%d %H:%M:%S")
        end
        unless params_issued_at == eva_issued_at
          evacuation_advisories_update_status = false
        end
        # 解除日時の確認
        params_lifted_at = nil
        eva_lifted_at = nil
        unless params[:evacuation_advisories]["#{eva.id}"][:lifted_at].blank?
          params_lifted_at = Time.parse(params[:evacuation_advisories]["#{eva.id}"][:lifted_at]).strftime("%Y-%m-%d %H:%M:%S")
        end
        unless eva[:lifted_at].blank?
          eva_lifted_at = eva[:lifted_at].strftime("%Y-%m-%d %H:%M:%S")
        end
        unless params_lifted_at == eva_lifted_at
          evacuation_advisories_update_status = false
        end
      end

      begin
      #　更新されているのに更新ボタンを押さないで登録ボタンを押した時にアラートを表示
      if evacuation_advisories_update_status
        # 発令区分の遷移履歴を更新する
        ActiveRecord::Base.transaction do
          @search = EvacuationAdvisory.mode_in(@project).search(params[:search])
          @evacuation_advisories = EvacuationAdvisory.mode_in(@project).paginate(:page => params[:page]).order("identifier ASC")
          @evacuation_advisories_for_ticket, sort_criteria_history = EvacuationAdvisory.update_sort_criteria_history(@project)
          if @evacuation_advisories_for_ticket.map{|ea| ea.errors.any? }.include?(true)
            render :action => :index
            raise RequiredException
          end

          # チケット作成
          issues = EvacuationAdvisory.create_issues(@project, :description => sort_criteria_history)
          links = []
          issues.each do |issue|
            links << view_context.link_to("##{issue.id}", issue_path(issue), :title => issue.subject)
          end
          flash[:notice] = l(:notice_issue_successful_create, :id => links.join(","))
        end
      else
        flash[:error] = l(:error_update_not_entry)
        return
      end
      rescue RequiredException
        return
      rescue ParamsException
        if EvacuationAdvisory.mode_in(@project).where(:current_sort_criteria => "2").exists?
          flash[:error] = l(:error_not_exists_commons_type_announcement)
        else
          flash[:error] = l(:error_not_exists_announcement)
        end
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
    @evacuation_advisory = EvacuationAdvisory.mode_in(@project).new
  end
  
  # 避難勧告･指示登録・更新画面
  # 初期表示処理（編集）
  # ==== Args
  # ==== Return
  # ==== Raise
  def edit
    @evacuation_advisory = EvacuationAdvisory.mode_in(@project).find(params[:id])
  end
  
  # 避難勧告･指示登録・更新画面
  # 登録処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def create
    @evacuation_advisory = EvacuationAdvisory.mode_in(@project).new()
    @evacuation_advisory.assign_attributes(params[:evacuation_advisory])

    if @evacuation_advisory.save
      flash[:notice] = l(:notice_evacuation_advisory_successful_create, :id => "##{@evacuation_advisory.id} #{@evacuation_advisory.headline}")
      # redirect_to :action  => :edit, :id => @evacuation_advisory.id
      redirect_to :action  => :index
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
    @evacuation_advisory = EvacuationAdvisory.mode_in(@project).find(params[:id])
    @evacuation_advisory.assign_attributes(params[:evacuation_advisory])
    if @evacuation_advisory.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action  => :index
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
    if EvacuationAdvisory.mode_in(@project).where("current_sort_criteria != ?", "1").exists?
      flash[:error] = l(:error_can_not_delete_announce)
      redirect_to :action  => :edit
    else
      @evacuation_advisory = EvacuationAdvisory.mode_in(@project).find(params[:id])
      if @evacuation_advisory.destroy
        flash[:notice] = l(:notice_successful_delete)
        redirect_to :action  => :index
      else
        render :action  => :edit
      end
    end
  end
  
end

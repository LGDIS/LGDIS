# encoding: utf-8
class SheltersController < ApplicationController
  unloadable
  
  accept_api_auth :index, :update
  before_filter :find_project_by_project_id, :authorize
  before_filter :init
  
  # 共通初期処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def init
    @shelter_const = Constant::hash_for_table(Shelter.table_name)
    @areas = Area.all
  end
  
  # 避難所一覧検索画面
  # 初期表示処理
  # 押下されたボタンにより処理を分岐
  # * 検索ボタンが押下された場合、検索条件を元に検索を行い結果を表示する
  # * クリアボタンが押下された場合、検索条件が未指定の状態で検索を行い結果を表示する
  # * 新規登録ボタンが押下された場合、避難所登録画面に遷移する
  # * 更新ボタンが押下された場合、避難所情報の一括更新を行う
  # * チケット登録ボタンが押下された場合、全ての避難所情報をXML化しチケットに登録する
  # ==== Args
  # _search_ :: 検索条件
  # _commit_kind_ :: ボタン種別
  # ==== Return
  # ==== Raise
  def index
    case params["commit_kind"]
    when "search"
      @search   = Shelter.search(params[:search])
      @shelters = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
      render :action => :index
    when "new"
      redirect_to :action => :new
    when "clear"
      @search   = Shelter.search
      @shelters = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
      render :action => :index
    when "bulk_update"
      bulk_update
    when "ticket"
      ticket
    else
      respond_to do |format|
        format.html {
          @search   = Shelter.search(params[:search])
          @shelters = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
          render :action => :index
        }
        format.api  {
          render :xml => Shelter.all.to_xml
        }
      end
    end
  end
  
  # 避難所一覧検索画面
  # ステータス更新処理
  # ==== Args
  # _shelters_ :: 避難所更新情報配列
  # ==== Return
  # ==== Raise
  def bulk_update
    if params[:shelters].present?
      shelter_id = params[:shelters].keys
      @search    = Shelter.search(:id_in => shelter_id)
      @shelters  = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
      begin
        Shelter.skip_callback(:save, :after, :execute_release_all_data)
        ActiveRecord::Base.transaction do
          @shelters.each do |shelter|
            shelter.assign_attributes(params[:shelters]["#{shelter.id}"], :as => :shelter)
            shelter.save
          end
          Shelter.release_all_data
        end
      ensure
        Shelter.set_callback(:save, :after, :execute_release_all_data)
      end
      # エラーが存在しない場合メッセージを出力する
      flash.now[:notice] = l(:notice_successful_update) unless @shelters.map{|sh| sh.errors.any? }.include?(true)
    else
      @search   = Shelter.search(params[:search])
      @shelters = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
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
    if Shelter.limit(1).present?
      begin
        issues = Shelter.create_issues(@project)
        links = []
        issues.each do |issue|
          links << view_context.link_to("##{issue.id}", issue_path(issue), :title => issue.subject)
        end
        flash[:notice] = l(:notice_issue_successful_create, :id => links.join(","))
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.record.errors.full_messages.join("<br>")
      end
    else
      flash[:error] = l(:error_not_exists_shelters)
    end
    redirect_to :action => :index
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
  # ==== Return
  # ==== Raise
  def edit
    @shelter = Shelter.find(params[:id])
  end
  
  # 避難所登録・更新画面
  # 登録処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def create
    @shelter = Shelter.new()
    @shelter.assign_attributes(params[:shelter], :as => :shelter)
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
  # ==== Return
  # ==== Raise
  def update
    @shelter = Shelter.find(params[:id])
    @shelter.assign_attributes(params[:shelter], :as => :shelter)
    if @shelter.save
      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html { redirect_to :action => :edit }
        format.api { render :xml => @shelter.to_xml }
      end
    else
      respond_to do |format|
        format.html { render :action  => :edit }
        format.api { render :xml => @shelter.errors.to_xml }
      end
    end
  end
  
  # 避難所登録・更新画面
  # 削除処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def destroy
    @shelter = Shelter.find(params[:id])
    if @shelter.destroy
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to :action  => :index
  end
  
end
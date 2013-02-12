# encoding: utf-8
class EvacuationAdvisoriesController < ApplicationController
  unloadable

  before_filter :find_project  #, :authorize
  before_filter :init

  # 共通初期処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def init
    @evacuation_advisory_const = Constant::hash_for_table(EvacuationAdvisory.table_name)
  end
  
  # 避難勧告･指示一覧検索画面
  # 初期表示処理
  # 押下されたボタンにより処理を分岐
  # ==== Args
  # _params[:search]_ :: 検索条件
  # _params[:commit_kind]_ :: ボタン種別
  # ==== Return
  # 検索ボタンが押下された場合、検索条件を元に検索を行い結果を表示する
  # クリアボタンが押下された場合、検索条件が未指定の状態で検索を行い結果を表示する
  # 新規登録ボタンが押下された場合、避難勧告･指示登録画面に遷移する
  # 更新ボタンが押下された場合、避難勧告･指示情報の一括更新を行う
  # チケット登録ボタンが押下された場合、全ての避難勧告･指示情報をXML化しチケットに登録する
  # 集計ボタンが押下された場合、LGDPMから避難者集計情報を取得し避難勧告･指示情報に登録する
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
    when "summary"
      summary
    else
      @search   = EvacuationAdvisory.search(params[:search])
      @evacuation_advisories = @search.paginate(:page => params[:page], :per_page => 30).order("identifier ASC")
      render :action => :index
    end
  end
  
  # 避難勧告･指示一覧検索画面
  # ステータス更新処理
  # ==== Args
  # _params[:evacuation_advisories]_ :: 避難勧告･指示更新情報配列
  # ==== Return
  # ==== Raise
  def bulk_update
    if params[:evacuation_advisories].present?
      eva_id = params[:evacuation_advisories].keys
      @search    = EvacuationAdvisory.search(:id_in => eva_id)
      @evacuation_advisories  = @search.paginate(:page => params[:page], :per_page => 30).order("identifier ASC")
      begin
        EvacuationAdvisory.skip_callback(:save, :after, :execute_release_all_data)
        ActiveRecord::Base.transaction do
          @evacuation_advisories.each do |eva|
            eva.sort_criteria = params[:evacuation_advisories]["#{eva.id}"]["sort_criteria"]
            eva.issue_or_lift = params[:evacuation_advisories]["#{eva.id}"]["issue_or_lift"]
            eva.issued_date   = params[:evacuation_advisories]["#{eva.id}"]["issued_date"]
            eva.issued_hm     = params[:evacuation_advisories]["#{eva.id}"]["issued_hm"]
            eva.lifted_date   = params[:evacuation_advisories]["#{eva.id}"]["lifted_date"]
            eva.lifted_hm     = params[:evacuation_advisories]["#{eva.id}"]["lifted_hm"]
            eva.save
          end
          EvacuationAdvisory.release_all_data
        end
      ensure
          EvacuationAdvisory.set_callback(:save, :after, :execute_release_all_data)
      end
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
    # 避難所情報が存在しない場合、処理しない
    if EvacuationAdvisory.where(:project_id => @project.id).present?
      begin
        issues = EvacuationAdvisory.create_issues(@project)
        links = []
        issues.each do |issue|
          links << view_context.link_to("##{issue.id}", issue_path(issue), :title => issue.subject)
        end
        flash[:notice] = l(:notice_issue_successful_create, :id => links.join(","))
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.message
      end
    else
      flash[:error] = l(:error_not_exists_evacuation_advisories)
    end
    redirect_to :action => :index
  end
#旧版
#   def ticket
#     #避難勧告･指示情報が存在しない場合、処理しない
#     if EvacuationAdvisory.where(:project_id => @project.id).present?
#       ActiveRecord::Base.transaction do
#         ### Applic用チケット登録
#         EvacuationAdvisory.create_applic_issue(@project)
#         ### 公共コモンズ用チケット登録
#         EvacuationAdvisory.create_commons_issue(@project)
#       end
#       flash[:notice] = "チケットを登録しました。"
#     else
#       flash[:error] = "避難勧告･指示情報が存在しません。"
#     end
#     redirect_to :action => :index
#   end

  
  # 避難勧告･指示一覧検索画面 
  # (画面上ではサマリー画面表示ボ ンが非活性化されているので､実際にはこの処理はよばれません)
  # 避難者情報サマリー処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def summary
    # LGDPMから避難者集計情報を取得する
    result = nil
    cookie = {}
    url    = URI.parse(SETTINGS["lgdpm"]["url"]) # LGDPMのIP
    Net::HTTP.start(url.host, url.port){|http|
      # ユーザ認証画面
      req1 = Net::HTTP::Post.new(SETTINGS["lgdpm"]["login_path"])
      # Basic認証の設定
      req1.basic_auth(SETTINGS["lgdpm"]["basic_auth"]["user"], SETTINGS["lgdpm"]["basic_auth"]["password"])
      # ユーザ認証の設定
      req1.set_form_data({'user[login]'=>SETTINGS["lgdpm"]["login"], 'user[password]'=>SETTINGS["lgdpm"]["password"]}, ';')
      res1 = http.request(req1)
      # 認証情報をCookieから取得
      res1.get_fields('Set-Cookie').each{|str| k,v = str[0...str.index(';')].split('='); cookie[k] = v}
      # 避難者情報取得
      req2 = Net::HTTP::Get.new(SETTINGS["lgdpm"]["index_path"], {'Cookie'=>cookie.map{|k,v| "#{k}=#{v}"}.join(';')})
      res2 = http.request(req2)
      # 取得した結果をパース
      result = JSON.parse(res2.body)
    }
    
    # 避難勧告･指示更新処理
    begin
      EvacuationAdvisory.skip_callback(:save, :after, :execute_release_all_data)
      ActiveRecord::Base.transaction do
        result.each do |r|
          # 避難勧告･指示識別番号を元に避難勧告･指示情報を取得
          evacuation_advisory = Evacuation_advisory.find_by_identifier(r["headline"])
          # 該当する避難勧告･指示がなければ処理しない
          next if evacuation_advisory.blank?
          # 対象人数
          evacuation_advisory.head_count = r["head_count"]
          # 対象世帯数
          evacuation_advisory.households = r["households"]

















          evacuation_advisory.save!
        end if result.present?
        EvacuationAdvisory.release_all_data
      end
    ensure
      EvacuationAdvisory.set_callback(:save, :after, :execute_release_all_data)
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
  
  # 避難勧告･指示登録・更新画面
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

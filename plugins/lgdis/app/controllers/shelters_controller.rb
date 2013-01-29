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
      @search   = Shelter.search(params[:search])
      @shelters = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
      render :action => :index
    when "new"
      redirect_to :action => :new
    when "clear"
      @search   = Shelter.where(:project_id => @project.id).search
      @shelters = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
      render :action => :index
    when "bulk_update"
      bulk_update
    when "ticket"
      ticket
    when "summary"
      summary
    else
      @search   = Shelter.search(params[:search])
      @shelters = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
      render :action => :index
    end
  end
  
  # 避難所一覧検索画面
  # ステータス更新処理
  # ==== Args
  # _params[:shelters]_ :: 避難所更新情報配列
  # ==== Return
  # ==== Raise
  def bulk_update
    if params[:shelters].present?
      shelter_id = params[:shelters].keys
      @search    = Shelter.search(:id_in => shelter_id)
      @shelters  = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
      ActiveRecord::Base.transaction do
        @shelters.each do |shelter|
          shelter.shelter_sort = params[:shelters]["#{shelter.id}"]["shelter_sort"]
          shelter.opened_date  = params[:shelters]["#{shelter.id}"]["opened_date"]
          shelter.opened_hm    = params[:shelters]["#{shelter.id}"]["opened_hm"]
          shelter.closed_date  = params[:shelters]["#{shelter.id}"]["closed_date"]
          shelter.closed_hm    = params[:shelters]["#{shelter.id}"]["closed_hm"]
          shelter.status       = params[:shelters]["#{shelter.id}"]["status"]
          shelter.save
        end
      end
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
    if Shelter.where(:project_id => @project.id).present?
      ActiveRecord::Base.transaction do
        ### Applic用チケット登録
        Shelter.create_applic_issue(@project)
        ### 公共コモンズ用チケット登録
        Shelter.create_commons_issue(@project)
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
    # LGDPMから避難者集計情報を取得する
    result = nil
    cookie = {}
    url    = URI.parse(SETTINGS["lgdpm"]["url"]) # LGDPMのIP
    Net::HTTP.start(url.host, url.port){|http|
      # ユーザ認証画面
      req1 = Net::HTTP::Post.new('/users/sign_in.json')
      # Basic認証の設定
      req1.basic_auth(SETTINGS["lgdpm"]["basic_auth"]["user"], SETTINGS["lgdpm"]["basic_auth"]["password"])
      # ユーザ認証の設定
      req1.set_form_data({'user[login]'=>SETTINGS["lgdpm"]["login"], 'user[password]'=>SETTINGS["lgdpm"]["password"]}, ';')
      res1 = http.request(req1)
      # 認証情報をCookieから取得
      res1.get_fields('Set-Cookie').each{|str| k,v = str[0...str.index(';')].split('='); cookie[k] = v}
      # 避難者情報取得
      req2 = Net::HTTP::Get.new('/evacuees/index.json', {'Cookie'=>cookie.map{|k,v| "#{k}=#{v}"}.join(';')})
      res2 = http.request(req2)
      # 取得した結果をパース
      result = JSON.parse(res2.body)
    }
    
    # 避難所更新処理
    ActiveRecord::Base.transaction do
      result.each do |r|
        # 避難所識別番号を元に避難所情報を取得
        shelter = Shelter.find_by_shelter_code(r["shelter_name"])
        # 該当する避難所がなければ処理しない
        next if shelter.blank?
        # 人数（自主避難人数を含む）
        shelter.head_count = r["head_count"]
        # 世帯数（自主避難世帯数を含む）
        # shelter.households = r["households_count"]
        # 負傷_計
        shelter.injury_count = r["injury_flag_count"]
        # 要介護度3以上_計
        shelter.upper_care_level_three_count = r["upper_care_level_three_count"]
        # 一人暮らし高齢者（65歳以上）_計
        shelter.elderly_alone_count = r["elderly_alone_count"]
        # 高齢者世帯（夫婦共に65歳以上）_計
        shelter.elderly_couple_count = r["elderly_couple_count"]
        # 寝たきり高齢者_計
        shelter.bedridden_elderly_count = r["bedridden_elderly_count"]
        # 認知症高齢者_計
        shelter.elderly_dementia_count = r["elderly_dementia_count"]
        # 療育手帳所持者_計
        shelter.rehabilitation_certificate_count = r["rehabilitation_certificate_count"]
        # 身体障害者手帳所持者_計
        shelter.physical_disability_certificate_count = r["physical_disability_certificate_count"]
        
        shelter.save!
      end if result.present?
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
    @shelter.project_id = @project.id
    @shelter.disaster_code = @project.disaster_code
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
    @shelter = Shelter.find(params[:id])
    if @shelter.destroy
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
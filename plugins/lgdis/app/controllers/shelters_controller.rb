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
      @search   = Shelter.mode_in(@project).search(params[:search])
      @shelters = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
      render :action => :index
    when "new"
      redirect_to :action => :new
    when "clear"
      @search   = Shelter.mode_in(@project).search
      @shelters = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
      render :action => :index
    when "bulk_update"
      bulk_update
    when "ticket"
      ticket
    else
      respond_to do |format|
        format.html {
          @search   = Shelter.mode_in(@project).search(params[:search])
          @shelters = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
          render :action => :index
        }
        format.api  {
          render :xml => Shelter.mode_in(@project).all.to_xml
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
      @search    = Shelter.mode_in(@project).search(:id_in => shelter_id)
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
      @search   = Shelter.mode_in(@project).search(params[:search])
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
    if Shelter.mode_in(@project).limit(1).present?
      # 避難所一覧画面で入力情報が更新されてるか確認
      shelters_update_status = true
      shelter_id = params[:shelters].keys
      @search   = Shelter.mode_in(@project).search(:id_in => shelter_id)
      @shelters = @search.paginate(:page => params[:page], :per_page => 30).order("shelter_code ASC")
      @shelters.each do |shelter|
        # 開設状況の確認
        unless params[:shelters]["#{shelter.id}"][:shelter_sort] == shelter[:shelter_sort]
          shelters_update_status = false
        end
        # 開設日時の確認
        params_opened_at = nil
        shelter_opened_at = nil
        unless params[:shelters]["#{shelter.id}"][:opened_at].blank?
          params_opened_at = Time.parse(params[:shelters]["#{shelter.id}"][:opened_at]).strftime("%Y-%m-%d %H:%M:%S")
        end
        unless shelter[:opened_at].blank?
          shelter_opened_at = shelter[:opened_at].strftime("%Y-%m-%d %H:%M:%S")
        end
        unless params_opened_at == shelter_opened_at
          shelters_update_status = false
        end
        # 閉鎖日時の確認
        params_closed_at = nil
        shelter_closed_at = nil
        unless params[:shelters]["#{shelter.id}"][:closed_at].blank?
          params_closed_at = Time.parse(params[:shelters]["#{shelter.id}"][:closed_at]).strftime("%Y-%m-%d %H:%M:%S")
        end
        unless shelter[:closed_at].blank?
          shelter_closed_at = shelter[:closed_at].strftime("%Y-%m-%d %H:%M:%S")
        end
        unless params_closed_at == shelter_closed_at
          shelters_update_status = false
        end
      end

      begin
      #　更新されているのに更新ボタンを押さないで登録ボタンを押した時にアラートを表示
      if shelters_update_status
        ticket_description = Shelter.get_description(Shelter.mode_in(@project).order(:shelter_code))
        issues = Shelter.create_issues(@project, :description => ticket_description)
        links = []
        issues.each do |issue|
          links << view_context.link_to("##{issue.id}", issue_path(issue), :title => issue.subject)
        end
        flash[:notice] = l(:notice_issue_successful_create, :id => links.join(","))
      else
        flash[:error] = l(:error_update_not_entry)
      end
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
    @shelter = Shelter.mode_in(@project).new
  end

  # 避難所登録・更新画面
  # 初期表示処理（編集）
  # ==== Args
  # ==== Return
  # ==== Raise
  def edit
    @shelter = Shelter.mode_in(@project).find(params[:id])
  end

  # 避難所登録・更新画面
  # 登録処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def create
    @shelter = Shelter.mode_in(@project).new()
    @shelter.assign_attributes(params[:shelter], :as => :shelter)
    if @shelter.save



  #避難所の住所から緯度経度を求めてそれをテーブルに代入
        geo = Hash.new
        geo = geocode(@shelter.address)
        setShelterGeoCsvArray(@shelter.name , geo)



      flash[:notice] = l(:notice_shelter_successful_create, :id => "##{@shelter.id} #{@shelter.name}")
      # redirect_to :action  => :edit, :id => @shelter.id
      redirect_to :action  => :index
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
    @shelter = Shelter.mode_in(@project).find(params[:id])
    @shelter.assign_attributes(params[:shelter], :as => :shelter)
    if @shelter.save

  #避難所の住所から緯度経度を求めてそれをテーブルに代入
        geo = Hash.new
        geo = geocode(@shelter.address)
        setShelterGeoCsvArray(@shelter.name , geo)


      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html { redirect_to :action => :index }
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
    forbit_criteria = ["2", "3", "4"]
    if Shelter.mode_in(@project).where("shelter_sort in (?)", forbit_criteria).exists?
      flash[:error] = l(:error_can_not_delete_set_up)
      redirect_to :action  => :edit
    else
      @shelter = Shelter.mode_in(@project).find(params[:id])
      if @shelter.destroy
        flash[:notice] = l(:notice_successful_delete)
        redirect_to :action  => :index
      else
        render :action  => :edit
      end
    end
  end

  def geocode(address)

  begin

     require 'rubygems'
     require 'net/http'
     require 'json'

     address = URI.encode(address)
     hash = Hash.new
     baseUrl = "http://maps.google.com/maps/api/geocode/json"
     reqUrl = "#{baseUrl}?address=#{address}&sensor=false&language=ja"
     response = Net::HTTP.get_response(URI.parse(reqUrl))
     status = JSON.parse(response.body)
     hash['lat'] = status['results'][0]['geometry']['location']['lat']
     hash['lng'] = status['results'][0]['geometry']['location']['lng']

     Rails.logger.info(hash)

     return hash

   rescue => e
     Rails.logger.info("geocode-error")
     Rails.logger.info(e.message)
     Rails.logger.info("geocode-error")
   end
  end

  def setShelterGeoCsvArray(shelter_name,geocodeArray)
    begin
      # fileに書き出し
    csv_dir_path  = "./tmp"
    csv_dir_path = csv_dir_path.gsub("./","")
    csv_file_name =  "/shelters_geographies.csv"
    csv_tmp_file_name =  "/shelters_geographies_tmp.csv"

    disk_fullpath_filename = Rails.root.to_s + "/" + csv_dir_path.to_s + csv_file_name
    new_csv_filename = Rails.root.to_s + "/" + csv_dir_path.to_s + csv_tmp_file_name

    #csv ファイルを読み込む 文字コード変換を行う
    reader = CSV.open(disk_fullpath_filename, "r" ,encoding: "SJIS:UTF-8")

    rows=[]

    new = true

      #CSV に避難所データがあるかどうか探す
      reader.each do |row|
        if row[0] == shelter_name then
          row[0] = row[0].to_s
          row[1] = geocodeArray["lat"].to_s
          row[2] = geocodeArray["lng"].to_s
          new = false
        end
        rows << row
      end

      #csv にデータがない場合は追加する
      if new then
        row_temp = Array.new
        row_temp[0] = shelter_name
        row_temp[1] = geocodeArray["lat"].to_s
        row_temp[2] = geocodeArray["lng"].to_s
        rows << row_temp
      end

      if FileTest.exist?(new_csv_filename) then
        File::delete(new_csv_filename)
      end
      Rails.logger.info("7")

      CSV.open(new_csv_filename, "a",encoding: "SJIS:UTF-8") do |csv|
        rows.each do |row|
          csv << row
        end
      end

      File::delete(disk_fullpath_filename)

      File::rename(new_csv_filename ,disk_fullpath_filename)

    rescue => e
      Rails.logger.info("setShelterGeoCsvArray" + e.message)
    end
  end

end

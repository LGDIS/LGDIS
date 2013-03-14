# encoding: utf-8
class DisasterDamageController < ApplicationController
  unloadable
  
  before_filter :find_project
  before_filter :authorize, :except => :show
  before_filter :init
  
  # 共通初期処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def init
    @disaster_damage_const = Constant::hash_for_table(DisasterDamage.table_name)
  end
  
  # 災害被害情報（第４号様式）画面
  # 初期表示処理
  # 押下されたボタンにより処理を分岐
  # ==== Args
  # _params[:commit_kind]_ :: ボタン種別
  # ==== Return
  # 保存ボタンが押下された場合、画面入力を保存する
  # チケット登録ボタンが押下された場合、選択されたトラッカーのチケットを登録する
  # ==== Raise
  # ==== Args
  # ==== Return
  # ==== Raise
  def index
    case params["commit_kind"]
    when "save"
      save
    when "ticket"
      ticket
    else
      @disaster_damage = DisasterDamage.first_or_initialize
    end
  end
  
  # 災害被害情報（第４号様式）画面
  # 保存処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def save
    @disaster_damage = DisasterDamage.has_no_issues.first_or_initialize
    @disaster_damage.assign_attributes(params[:disaster_damage])
    if @disaster_damage.save
      flash[:notice] = l(:notice_disaster_damage_successful_save)
      redirect_to :action  => :index
    else
      render :action  => :index
    end
  end
  
  # 災害被害情報（第４号様式）画面
  # チケット登録処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def ticket
    if params[:tracker_id].blank?
      flash[:error] = l(:text_select_tracker)
    elsif (dd = DisasterDamage.first).present?
      begin
        issues = dd.create_issues(@project, params[:tracker_id])
        links = []
        issues.each do |issue|
          links << view_context.link_to("##{issue.id}", issue_path(issue), :title => issue.subject)
          issue.init_journal(User.current, "\"第４号様式へのリンク\":#{url_for(controller: 'disaster_damage', action: 'show', id: dd.id)}") # 履歴
          issue.save!
        end
        flash[:notice] = l(:notice_issue_successful_create, :id => links.join(","))
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.record.errors.full_messages.join("<br>")
      end
    else
      # 災害被害情報が存在しない場合、処理しない
      flash[:error] = l(:error_not_exists_disaster_damage)
    end
    redirect_to :action => :index
  end
  
  # 災害被害情報（第４号様式）画面
  # 照会処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def show
    @disaster_damage = DisasterDamage.find(params[:id])
    render :action  => :index
  rescue ActiveRecord::RecordNotFound
    render_404
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
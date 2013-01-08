# encoding: utf-8
class SheltersController < ApplicationController
  unloadable
  
  before_filter :find_project, :authorize
  before_filter :init
  
  def init
    @shelter_const = Constant::hash_for_table(Shelter.table_name)
  end
  
  def index
  end
  
  def new
    @shelter = Shelter.new
  end
  
  def edit
    @shelter = Shelter.find(params[:id])
  end
  
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
  
  def destroy
    @shelter = Shelter.find(params[:id])
    if @shelter.destroy
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to :action  => :index
  end
  
  private
  
  def find_project
    # authorize filterの前に、@project にセットする
    @project = Project.find(params[:project_id])
  end
  
end
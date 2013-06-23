# -*- coding:utf-8 -*-
require 'spec_helper'

describe SheltersController do
  before do
    ApplicationController.any_instance.stub(:authorize) {true}
    login_required = Setting.find_by_name('login_required')
    login_required.value = 0
    login_required.save!
    
    ApplicationController.any_instance.stub(:get_cache) {{"area1" =>"地区名1"}}
    
    @project = FactoryGirl.build(:project1, :id => 5)
    @project.save!
  end
  let(:project_id) { @project.id }

  describe "#init " do
    it "call once by before_filter" do
      controller.should_receive(:init).once
      get :index, { "commit_kind"=>"new",  "project_id"=>project_id}
    end
    it "get shelter_const" do
      get :index, { "commit_kind"=>"new",  "project_id"=>project_id}
      assigns[:shelter_const].should == Constant::hash_for_table(Shelter.table_name)
    end
    it "get area" do
      controller.should_receive(:get_cache).with("area").and_return({"area1" =>"地区名1"})
      get :index, { "commit_kind"=>"new",  "project_id"=>project_id}
      assigns[:area].should == {"area1" =>"地区名1"}
    end
  end


  describe "#index search" do
    before do
     @shelter_search_ary =[]
      1.upto(35) do |num|
        shelter = FactoryGirl.build(:shelter1, :shelter_code => format("%4d", num), :name =>"避難所名"+"#{num}")
        shelter.save!
      end

      36.upto(70) do |num|
        shelter = FactoryGirl.build(:shelter1, :shelter_code => format("%4d", num), :name =>"避難所名"+"#{num}", :shelter_type => "2")
        shelter.save!
        @shelter_search_ary << shelter if @shelter_search_ary.size < 30
      end

      get :index, {"utf8"=>"?",
                   "commit_kind"=>"search", 
                   "search"=>{"shelter_type_eq"=>"2", 
                              "usable_flag_eq"=>"", 
                              "opened_at_gte"=>"", 
                              "opened_at_lte"=>"", 
                              "openable_flag_eq"=>"", 
                              "closed_at_gte"=>"", 
                              "closed_at_lte"=>"", 
                              "status_eq"=>"", 
                              "households_gte"=>"", 
                              "upper_care_level_three_count_gte"=>"", 
                              "bedridden_elderly_count_gte"=>"", 
                              "physical_disability_certificate_count_gte"=>"", 
                              "head_count_gte"=>"", 
                              "elderly_alone_count_gte"=>"", 
                              "elderly_dementia_count_gte"=>"", 
                              "injury_count_gte"=>"", 
                              "elderly_couple_count_gte"=>"", 
                              "rehabilitation_certificate_count_gte"=>"", 
                              "note_like"=>""}, 
                   "commit"=>"検索", 
                   "controller"=>"shelters", 
                   "action"=>"index", 
                   "project_id"=>project_id}
    end
    it "response success" do
      response.should be_success
    end
    it "render index" do
      response.should render_template("index")
    end
    it "get search shelter list" do
      assigns[:shelters].should == @shelter_search_ary
    end
  end

  describe "#index new" do
    before do
      get :index, { "commit_kind"=>"new",  "project_id"=>project_id}
    end
    it "redirect to new" do
      response.should redirect_to(:action => :new)
    end
  end

  describe "#index clear" do
    before do
      Shelter.delete_all! # Projectデータ作成の際に、Shelterのデータも作成されるので一旦削除する
      @shelter_clear_ary =[]
      1.upto(35) do |num|
        shelter = FactoryGirl.build(:shelter1, :shelter_code => format("%4d", num), :name =>"避難所名"+"#{num}")
        shelter.save!
        @shelter_clear_ary << shelter if @shelter_clear_ary.size < 30
      end

      get :index, { "commit_kind"=>"clear",  "project_id"=>project_id}
    end
    it "response success" do
      response.should be_success
    end
    it "render index" do
      response.should render_template("index")
    end
    it "get clear shelter list" do
      assigns[:shelters].should == @shelter_clear_ary
    end
  end

  describe "#index bulk_update" do
    it "render index" do
      get :index, { "commit_kind"=>"bulk_update",  "project_id"=>project_id}
      response.should render_template("index")
    end
    it "call once" do
      controller.should_receive(:bulk_update).once
      get :index, { "commit_kind"=>"bulk_update",  "project_id"=>project_id}
    end
  end

  describe "#index ticket" do
    before do
    end
    it "redirect to index" do
      get :index, { "commit_kind"=>"ticket",  "project_id"=>project_id}
      response.should redirect_to(:action => :index)
    end
    it "call once" do
      controller.should_receive(:ticket).once
      get :index, { "commit_kind"=>"ticket",  "project_id"=>project_id}
    end
  end

  describe "#index summary" do
    before do
      Net::HTTP.stub(:start) {true} # LGDPMとの通信,避難所更新処理を回避
    end
    it "redirect to index" do
      get :index, { "commit_kind"=>"summary",  "project_id"=>project_id}
      response.should redirect_to(:action => :index)
    end
    it "call once" do
      controller.should_receive(:summary).once
      get :index, { "commit_kind"=>"summary",  "project_id"=>project_id}
    end
  end

  describe "#index else" do
    before do
      Shelter.delete_all!
      @shelter_clear_ary =[]
      1.upto(35) do |num|
        shelter = FactoryGirl.build(:shelter1, :shelter_code => format("%4d", num), :name =>"避難所名"+"#{num}")
        shelter.save!
        @shelter_clear_ary << shelter if @shelter_clear_ary.size < 30
      end

      get :index, { "commit_kind"=>"aaa_else_aaa",  "project_id"=>project_id}
    end
    it "response success" do
      response.should be_success
    end
    it "render index" do
      response.should render_template("index")
    end
    it "get clear shelter list" do
      assigns[:shelters].should == @shelter_clear_ary
    end
  end


  describe "#bulk_update " do
    describe "if param shelters present" do
      before do
        @shelter_update_ary=[]
        @param_shelters_hash={}
        1.upto(35) do |num|
          shelter = FactoryGirl.build(:shelter1, :shelter_code => format("%4d", num), :name =>"避難所名"+"#{num}")
          shelter.save!
          @shelter_update_ary << shelter if @shelter_update_ary.size < 30
          
          @shelter_update_ary.each do |shelter| 
            @param_shelters_hash["#{shelter.id}"] = {"shelter_sort" =>"2", "opened_date" =>"2013-02-01", "opened_hm" =>"00:00", "closed_date" =>"2013-02-05", "closed_hm" =>"11:11", "status" =>"2", } 
          end
          
        end
        post :bulk_update, {"utf8"=>"?",  "commit_kind"=>"bulk_update", "shelters"=>@param_shelters_hash, "project_id"=>project_id}
      end
      it "update shelters " do
        shelter_id = @param_shelters_hash.keys
        search    = Shelter.search(:id_in => shelter_id)
        shelters  = search.paginate(:page =>1, :per_page => 30).order("shelter_code ASC")
        shelters.each do |shelter|
          shelter.shelter_sort.should == @param_shelters_hash["#{shelter.id}"]["shelter_sort"]
          #shelter.opened_date.should  == @param_shelters_hash["#{shelter.id}"]["opened_date"] # TODO: 取得すると日付フォーマットが「Fri, 01 Feb 2013」なるので保留
          shelter.opened_hm.should    == @param_shelters_hash["#{shelter.id}"]["opened_hm"]
          #shelter.closed_date.should  == @param_shelters_hash["#{shelter.id}"]["closed_date"] # TODO: 取得すると日付フォーマットが「Fri, 01 Feb 2013」なるので保留
          shelter.closed_hm.should    == @param_shelters_hash["#{shelter.id}"]["closed_hm"]
          shelter.status.should       == @param_shelters_hash["#{shelter.id}"]["status"]
        end
      end
    end
    describe "if param shelters not present" do
      before do
        @shelter_not_update_ary=[]
        1.upto(35) do |num|
          shelter = FactoryGirl.build(:shelter1, :shelter_code => format("%4d", num), :name =>"避難所名"+"#{num}")
          shelter.save!
        end

        36.upto(70) do |num|
          shelter = FactoryGirl.build(:shelter1, :shelter_code =>format("%4d", num), :name =>"避難所名"+"#{num}", :shelter_type => "2")
          shelter.save!
          @shelter_not_update_ary << shelter if @shelter_not_update_ary.size < 30
        end
          
        post :bulk_update, {"utf8"=>"?",
                            "commit_kind"=>"bulk_update", 
                            "search"=>{"shelter_type_eq"=>"2", 
                                       "usable_flag_eq"=>"", 
                                       "opened_at_gte"=>"", 
                                       "opened_at_lte"=>"", 
                                       "openable_flag_eq"=>"", 
                                       "closed_at_gte"=>"", 
                                       "closed_at_lte"=>"", 
                                       "status_eq"=>"", 
                                       "households_gte"=>"", 
                                       "upper_care_level_three_count_gte"=>"", 
                                       "bedridden_elderly_count_gte"=>"", 
                                       "physical_disability_certificate_count_gte"=>"", 
                                       "head_count_gte"=>"", "elderly_alone_count_gte"=>"", 
                                       "elderly_dementia_count_gte"=>"", 
                                       "injury_count_gte"=>"", 
                                       "elderly_couple_count_gte"=>"", 
                                       "rehabilitation_certificate_count_gte"=>"", 
                                       "note_like"=>""}, 
                            "controller"=>"shelters", 
                            "action"=>"index", 
                            "project_id"=>project_id}
      end
      
      it "get not update shelter list " do
        assigns[:shelters].should == @shelter_not_update_ary
        
      end
    end
  end


  describe "#ticket " do
    before do
    end
    describe "if shelter present" do
      before do
        shelter = FactoryGirl.build(:shelter1, :shelter_code => "1")
        shelter.save!
        @issue = mock_model(Issue)
        @issue.stub(:subject) {"避難所情報 YYYY/MM/DD hh:mm:ss"}
      end
      it "Shelter.create_issues " do
        Shelter.should_receive(:create_issues).with(@project).and_return([@issue])
        post :ticket, { "commit_kind"=>"ticket",  "project_id"=>project_id}
      end
      it "set flash " do
        Shelter.should_receive(:create_issues).with(@project).and_return([@issue])
        post :ticket, { "commit_kind"=>"ticket",  "project_id"=>project_id}
        flash[:notice].should == "チケット <a href=\"/issues/#{@issue.id}\" title=\"#{@issue.subject}\">##{@issue.id}</a> が作成されました。"
      end
    end
    describe "if shelter not present" do
      before do
        Shelter.delete_all!
      end
      it "set flash " do
        post :ticket, { "commit_kind"=>"ticket",  "project_id"=>project_id}
        flash[:error].should == "避難所情報が存在しません。"
      end
    end
  end


  describe "#summary " do
    before do
      #post :summary, {:project_id=>project_id}
    end
    it "" do
      pending("通信の回避とresultの取得が両立せず要検討")
    end
  end


  describe "#new " do
    before do
      get :new, {:project_id=>project_id}
    end
    it "new Shelter" do
      assigns[:shelter].should be_a_new(Shelter)
    end
  end


  describe "#edit " do
    before do
      @shelter = FactoryGirl.build(:shelter1, :shelter_code => format("%4d", 1))
      @shelter.save!
      
      get :edit, {:project_id=>project_id, :id=>@shelter.id}
    end
    it "get shelter" do
      assigns[:shelter].should == @shelter
    end
  end


  describe "#create " do
    before do
      Shelter.delete_all!
      @shelter_param = {
        :area         => '地区名',
        :name         => '名前',
        :name_kana    => 'カナ',
        :address      => '住所',
        :phone        => '0312345678',
        :fax          => '0312345679',
        :shelter_type => '1',
        :shelter_sort => '1',
        :shelter_code => '1',
      }
    end
    describe "shelter.save success" do
      before do
        post :create, {:project_id => project_id, :shelter=>@shelter_param}
      end
      it "redirect to edit " do
        shelter = Shelter.first
        response.should redirect_to(:action => :edit, :id =>shelter.id)
      end
      it "set flash " do
        shelter = Shelter.first
        flash[:notice].should == "避難所 ##{shelter.id} #{shelter.name} が作成されました。"
      end
    end
    describe "shelter.save failer" do
      before do
        Shelter.any_instance.stub(:save) {false}
        post :create, {:project_id => project_id, :shelter=>@shelter_param}
      end
      it "render new " do
        response.should render_template("new")
      end
    end
  end


  describe "#update " do
    before do
      @shelter = FactoryGirl.build(:shelter1, :shelter_code => format("%4d", 1))
      @shelter.save!
      
      @shelter_param = {
        :name         => '名前',
        :name_kana    => 'カナ',
        :address      => '住所',
        :phone        => '0312345678',
        :fax          => '0312345679',
        :shelter_type => '1',
        :shelter_sort => '1',
        :shelter_code => '1',
      }
    end
     describe "shelter.save success" do
      before do
        put :update, {:project_id => project_id, :shelter=>@shelter_param, :id=>@shelter.id}
      end
      it "redirect to edit " do
        response.should redirect_to(:action => :edit)
      end
      it "set flash " do
        flash[:notice].should == "更新しました。"
      end
    end
    describe "shelter.save failer" do
      before do
        Shelter.any_instance.stub(:save) {false}
        put :update, {:project_id => project_id, :shelter=>@shelter_param, :id=>@shelter.id}
      end
      it "render new " do
        response.should render_template("edit")
      end
    end
  end


  describe "#destroy " do
    before do
      @shelter = FactoryGirl.build(:shelter1, :shelter_code => format("%4d", 1))
      @shelter.save!
      
    end
     describe "shelter.save success" do
      before do
        delete :destroy, {:project_id => project_id, :id=>@shelter.id}
      end
      it "redirect to index " do
        response.should redirect_to(:action => :index)
      end
      it "set flash " do
        flash[:notice].should == "削除しました。"
      end
    end
    describe "shelter.save failer" do
      before do
        Shelter.any_instance.stub(:destroy) {false}
        delete :destroy, {:project_id => project_id, :id=>@shelter.id}
      end
      it "not set flash " do
        controller.should_not set_the_flash
      end
    end
  end


  describe "#find_project" do
    it "call once by before_filter" do
      controller.should_receive(:find_project).once
      get :index, {:project_id => project_id, "commit_kind" => "new"}
    end
    it "get project" do
      get :index, {:project_id => project_id, "commit_kind" => "new"}
      assigns[:project].should == @project
    end
  end

end

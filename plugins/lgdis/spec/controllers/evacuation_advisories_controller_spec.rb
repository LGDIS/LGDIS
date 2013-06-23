# -*- coding:utf-8 -*-
require 'spec_helper.rb'

describe EvacuationAdvisoriesController do
  before do
    ApplicationController.any_instance.stub(:authorize) {true}
    login_required = Setting.find_by_name('login_required')
    login_required.value = "0"
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
    it "get evacuation_advisory_const" do
      get :index, { "commit_kind"=>"new",  "project_id"=>project_id}
      assigns[:evacuation_advisory_const].should == Constant::hash_for_table(EvacuationAdvisory.table_name)
    end
    it "get area" do
      controller.should_receive(:get_cache).with("area").and_return({"area1" =>"地区名1"})
      get :index, { "commit_kind"=>"new",  "project_id"=>project_id}
      assigns[:area].should == {"area1" =>"地区名1"}
    end
  end


  describe "#index search" do
    before do
     @evacuation_advisory_search_ary =[]
      1.upto(35) do |num|
        evacuation_advisory = FactoryGirl.build(:evacuation_advisory1, :identifier => format("%4d", num), :area =>"避難勧告･指示名"+"#{num}")
        evacuation_advisory.save!
      end

      36.upto(70) do |num|
        evacuation_advisory = FactoryGirl.build(:evacuation_advisory1, :identifier => format("%4d", num), :area =>"避難勧告･指示名"+"#{num}", :advisory_type => "2")
        evacuation_advisory.save!
        @evacuation_advisory_search_ary << evacuation_advisory if @evacuation_advisory_search_ary.size < 30
      end

      get :index, {"utf8"=>"?",
                   "commit_kind"=>"search", 
                   "search"=>{"advisory_type_eq"=>"2", 
                              "issued_at_gte"=>"", 
                              "issued_at_lte"=>"", 
                              "lifted_at_gte"=>"", 
                              "lifted_at_lte"=>"", 
                              "issueorlift_eq"=>"", 
                              "households_gte"=>"", 
                              "head_count_gte"=>"", 
                              "remarks_like"=>""}, 
                   "commit"=>"検索", 
                   "controller"=>"evacuation_advisories", 
                   "action"=>"index", 
                   "project_id"=>project_id}
    end
    it "response success" do
      response.should be_success
    end
    it "render index" do
      response.should render_template("index")
    end
    it "get search evacuation_advisory list" do
      assigns[:evacuation_advisories].should == @evacuation_advisory_search_ary
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
      EvacuationAdvisory.delete_all! # Projectデータ作成の際に、EvacuationAdvisoryのデータも作成されるので一旦削除する
      @evacuation_advisory_clear_ary =[]
      1.upto(35) do |num|
        evacuation_advisory = FactoryGirl.build(:evacuation_advisory1, :identifier => format("%4d", num), :area =>"避難勧告･指示名"+"#{num}")
        evacuation_advisory.save!
        @evacuation_advisory_clear_ary << evacuation_advisory if @evacuation_advisory_clear_ary.size < 30
      end

      get :index, { "commit_kind"=>"clear",  "project_id"=>project_id}
    end
    it "response success" do
      response.should be_success
    end
    it "render index" do
      response.should render_template("index")
    end
    it "get clear evacuation_advisory list" do
      assigns[:evacuation_advisories].should == @evacuation_advisory_clear_ary
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


  describe "#index else" do
    before do
      EvacuationAdvisory.delete_all!
      @evacuation_advisory_clear_ary =[]
      1.upto(35) do |num|
        evacuation_advisory = FactoryGirl.build(:evacuation_advisory1, :identifier => format("%4d", num), :area =>"避難勧告･指示名"+"#{num}")
        evacuation_advisory.save!
        @evacuation_advisory_clear_ary << evacuation_advisory if @evacuation_advisory_clear_ary.size < 30
      end

      get :index, { "commit_kind"=>"aaa_else_aaa",  "project_id"=>project_id}
    end
    it "response success" do
      response.should be_success
    end
    it "render index" do
      response.should render_template("index")
    end
    it "get clear evacuation_advisory list" do
      assigns[:evacuation_advisories].should == @evacuation_advisory_clear_ary
    end
  end


  describe "#bulk_update " do
    describe "if param evacuation_advisories present" do
      before do
        @evacuation_advisory_update_ary=[]
        @param_evacuation_advisories_hash={}
        1.upto(35) do |num|
          evacuation_advisory = FactoryGirl.build(:evacuation_advisory1, :identifier => format("%4d", num), :area =>"避難勧告･指示名"+"#{num}")
          evacuation_advisory.save!
          @evacuation_advisory_update_ary << evacuation_advisory if @evacuation_advisory_update_ary.size < 30
          
          @evacuation_advisory_update_ary.each do |evacuation_advisory| 
            @param_evacuation_advisories_hash["#{evacuation_advisory.id}"] = {"sort_criteria" =>"2", "issued_date" =>"2013-02-01", "issued_hm" =>"00:00", "lifted_date" =>"2013-02-05", "lifted_hm" =>"11:11", "issueorlift" =>"1", } 
          end
          
        end
        post :bulk_update, {"utf8"=>"?",  "commit_kind"=>"bulk_update", "evacuation_advisories"=>@param_evacuation_advisories_hash, "project_id"=>project_id}
      end
      it "update evacuation_advisories " do
        evacuation_advisory_id = @param_evacuation_advisories_hash.keys
        search    = EvacuationAdvisory.search(:id_in => evacuation_advisory_id)
        evacuation_advisories  = search.paginate(:page =>1, :per_page => 30).order("identifier ASC")
        evacuation_advisories.each do |evacuation_advisory|
          evacuation_advisory.sort_criteria.should == @param_evacuation_advisories_hash["#{evacuation_advisory.id}"]["sort_criteria"]
          #evacuation_advisory.issued_date.should  == @param_evacuation_advisories_hash["#{evacuation_advisory.id}"]["issued_date"] # TODO: 取得すると日付フォーマットが「Fri, 01 Feb 2013」なるので保留
          evacuation_advisory.issued_hm.should    == @param_evacuation_advisories_hash["#{evacuation_advisory.id}"]["issued_hm"]
          #evacuation_advisory.lifted_date.should  == @param_evacuation_advisories_hash["#{evacuation_advisory.id}"]["lifted_date"] # TODO: 取得すると日付フォーマットが「Fri, 01 Feb 2013」なるので保留
          evacuation_advisory.lifted_hm.should    == @param_evacuation_advisories_hash["#{evacuation_advisory.id}"]["lifted_hm"]
          evacuation_advisory.issueorlift.should       == @param_evacuation_advisories_hash["#{evacuation_advisory.id}"]["issueorlift"]
        end
      end
    end
    describe "if param evacuation_advisories not present" do
      before do
        @evacuation_advisory_not_update_ary=[]
        1.upto(35) do |num|
          evacuation_advisory = FactoryGirl.build(:evacuation_advisory1, :identifier => format("%4d", num), :area =>"避難勧告･指示名"+"#{num}")
          evacuation_advisory.save!
        end

        36.upto(70) do |num|
          evacuation_advisory = FactoryGirl.build(:evacuation_advisory1, :identifier =>format("%4d", num), :area =>"避難勧告･指示名"+"#{num}", :advisory_type => "2")
          evacuation_advisory.save!
          @evacuation_advisory_not_update_ary << evacuation_advisory if @evacuation_advisory_not_update_ary.size < 30
        end
          
        post :bulk_update, {"utf8"=>"?",
                            "commit_kind"=>"bulk_update", 
                            "search"=>{"advisory_type_eq"=>"2", 
                                       "issued_at_gte"=>"", 
                                       "issued_at_lte"=>"", 
                                       "lifted_at_gte"=>"", 
                                       "lifted_at_lte"=>"", 
                                       "issueorlift_eq"=>"", 
                                       "households_gte"=>"", 
                                       "head_count_gte"=>"",
                                       "remarks_like"=>""}, 
                            "controller"=>"evacuation_advisories", 
                            "action"=>"index", 
                            "project_id"=>project_id}
      end
      
      it "get not update evacuation_advisory list " do
        assigns[:evacuation_advisories].should == @evacuation_advisory_not_update_ary
        
      end
    end
  end


  describe "#ticket " do
    before do
    end
    describe "if evacuation_advisory present" do
      before do
        evacuation_advisory = FactoryGirl.build(:evacuation_advisory1, :identifier => "1")
        evacuation_advisory.save!
        @issue = mock_model(Issue)
        @issue.stub(:subject) {"避難勧告･指示情報 YYYY/MM/DD hh:mm:ss"}
      end
      it "EvacuationAdvisory.create_issues " do
        EvacuationAdvisory.should_receive(:create_issues).with(@project).and_return([@issue])
        post :ticket, { "commit_kind"=>"ticket",  "project_id"=>project_id}
      end
      it "set flash " do
        EvacuationAdvisory.should_receive(:create_issues).with(@project).and_return([@issue])
        post :ticket, { "commit_kind"=>"ticket",  "project_id"=>project_id}
        flash[:notice].should == "チケット <a href=\"/issues/#{@issue.id}\" title=\"#{@issue.subject}\">##{@issue.id}</a> が作成されました。"
      end
    end
    describe "if evacuation_advisory not present" do
      before do
        EvacuationAdvisory.delete_all!
      end
      it "set flash " do
        post :ticket, { "commit_kind"=>"ticket",  "project_id"=>project_id}
        flash[:error].should == "避難勧告･指示情報が存在しません。"
      end
    end
  end



  describe "#new " do
    before do
      get :new, {:project_id=>project_id}
    end
    it "new EvacuationAdvisory" do
      assigns[:evacuation_advisory].should be_a_new(EvacuationAdvisory)
    end
  end


  describe "#edit " do
    before do
      @evacuation_advisory = FactoryGirl.build(:evacuation_advisory1, :identifier => format("%4d", 1))
      @evacuation_advisory.save!
      
      get :edit, {:project_id=>project_id, :id=>@evacuation_advisory.id}
    end
    it "get evacuation_advisory" do
      assigns[:evacuation_advisory].should == @evacuation_advisory
    end
  end


  describe "#create " do
    before do
      EvacuationAdvisory.delete_all!
      @evacuation_advisory_param = {
        :area         => '地区名',
        :area_kana    => 'カナ',
        :phone        => '0312345678',
        :fax          => '0312345679',
        :advisory_type => '1',
        :sort_criteria => '1',
        :identifier => '1',
      }
    end
    describe "evacuation_advisory.save success" do
      before do
        post :create, {:project_id => project_id, :evacuation_advisory=>@evacuation_advisory_param}
      end
      it "redirect to edit " do
        evacuation_advisory = EvacuationAdvisory.first
        response.should redirect_to(:action => :edit, :id =>evacuation_advisory.id)
      end
      it "set flash " do
        evacuation_advisory = EvacuationAdvisory.first
        flash[:notice].should == "避難勧告･指示 ##{evacuation_advisory.id} #{evacuation_advisory.headline} が作成されました。"
      end
    end
    describe "evacuation_advisory.save failer" do
      before do
        EvacuationAdvisory.any_instance.stub(:save) {false}
        post :create, {:project_id => project_id, :evacuation_advisory=>@evacuation_advisory_param}
      end
      it "render new " do
        response.should render_template("new")
      end
    end
  end


  describe "#update " do
    before do
      @evacuation_advisory = FactoryGirl.build(:evacuation_advisory1, :identifier => format("%4d", 1))
      @evacuation_advisory.save!
      
      @evacuation_advisory_param = {
        :area         => '名前',
        :area_kana    => 'カナ',
        :phone        => '0312345678',
        :fax          => '0312345679',
        :advisory_type => '1',
        :sort_criteria => '1',
        :identifier => '1',
      }
    end
     describe "evacuation_advisory.save success" do
      before do
        put :update, {:project_id => project_id, :evacuation_advisory=>@evacuation_advisory_param, :id=>@evacuation_advisory.id}
      end
      it "redirect to edit " do
        response.should redirect_to(:action => :edit)
      end
      it "set flash " do
        flash[:notice].should == "更新しました。"
      end
    end
    describe "evacuation_advisory.save failer" do
      before do
        EvacuationAdvisory.any_instance.stub(:save) {false}
        put :update, {:project_id => project_id, :evacuation_advisory=>@evacuation_advisory_param, :id=>@evacuation_advisory.id}
      end
      it "render new " do
        response.should render_template("edit")
      end
    end
  end


  describe "#destroy " do
    before do
      @evacuation_advisory = FactoryGirl.build(:evacuation_advisory1, :identifier => format("%4d", 1))
      @evacuation_advisory.save!
      
    end
     describe "evacuation_advisory.save success" do
      before do
        delete :destroy, {:project_id => project_id, :id=>@evacuation_advisory.id}
      end
      it "redirect to index " do
        response.should redirect_to(:action => :index)
      end
      it "set flash " do
        flash[:notice].should == "削除しました。"
      end
    end
    describe "evacuation_advisory.save failer" do
      before do
        EvacuationAdvisory.any_instance.stub(:destroy) {false}
        delete :destroy, {:project_id => project_id, :id=>@evacuation_advisory.id}
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

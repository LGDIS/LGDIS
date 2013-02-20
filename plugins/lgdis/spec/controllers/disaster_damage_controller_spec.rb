# -*- coding:utf-8 -*-
require 'spec_helper'

describe DisasterDamageController do
  before do
    ApplicationController.any_instance.stub(:authorize) {true}
    login_required = Setting.find_by_name('login_required')
    login_required.value = 0
    login_required.save!
    
    ApplicationController.any_instance.stub(:get_cache) {{"area1" =>"地区名1"}}
    
    @project = FactoryGirl.build(:project1, :id => 6)
    @project.save!
  end
  let(:project_id) { @project.id }

  describe "#init " do
    it "call once by before_filter" do
      controller.should_receive(:init).once
      get :index, { "commit_kind"=>"new",  "project_id"=>project_id}
    end
    it "get disaster_damage_const" do
      get :index, { "commit_kind"=>"new",  "project_id"=>project_id}
      assigns[:disaster_damage_const].should == Constant::hash_for_table(DisasterDamage.table_name)
    end
  end

  describe "#index save" do
    before do
    end
    it "call once by before_filter" do
      controller.should_receive(:save).once
      get :index, { "commit_kind"=>"save",  "project_id"=>project_id}
    end
    it "call once" do
      get :index, { "commit_kind"=>"save",  "project_id"=>project_id}
      response.should redirect_to(:action => :index)
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
      get :index, { "commit_kind"=>"",  "project_id"=>project_id}
    end
    it "not nil" do
      assigns[:disaster_damage].should_not be_nil
    end
    it "instance of DisasterDamage" do
      assigns[:disaster_damage].should be_instance_of(DisasterDamage)
    end
  end

  describe "#save" do
    before do
      get :index, { "commit_kind"=>"save",  "project_id"=>project_id}
      @disaster_damage = assigns[:disaster_damage]
    end
    context "@disaster_damage.save success" do
      before "save success" do
        @disaster_damage.stub!(:save).and_return(true)
      end
      it "flash messeage" do
        flash[:notice].should == "災害被害情報が保存されました。"
      end
      it "redirect to index" do
        response.should redirect_to(:action => :index)
      end
    end
    context "@disaster_damage.save fail" do
      it "render_to index" do
        pending "no route error post missed" do
          @disaster_damage.stub!(:save).and_return(false)
          post :save, { "commit_kind"=>"save",  "project_id"=>project_id }
          response.should render_template(:action => :save)
        end
      end
    end
  end

  describe "#ticket " do
    describe "" do
      before do
        DisasterDamage.delete_all
      end
      it " " do
        pending "no route error post missed" do
          post :ticket, { "commit_kind"=>"ticket",  "project_id"=>project_id }
        end
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

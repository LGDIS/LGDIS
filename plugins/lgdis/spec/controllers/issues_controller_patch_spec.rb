# -*- coding:utf-8 -*-
require 'spec_helper'

describe IssuesController do
  before do
    ApplicationController.any_instance.stub(:authorize) {true}
    login_required = Setting.find_by_name('login_required')
    login_required.value = 0
    login_required.save!

    ApplicationController.any_instance.stub(:get_cache).with("area").and_return({"area1" =>"地区名1"})
    ApplicationController.any_instance.stub(:get_cache).with("River【XMLSchema_C】.WaringConstCause").and_return("ret_waring_const_cause")
    ApplicationController.any_instance.stub(:get_cache).with("River【XMLSchema_C】.WaringConstApply").and_return("ret_waring_const_apply")

    @project = FactoryGirl.build(:project1, :id => 5)
    @project.save!
  end
  let(:project_id) { @project.id }

  describe "#build_new_issue_geography_from_params " do
    describe "params[:issue][:issue_geographies] present " do
      before do
        post :create, {:project_id=>project_id, :issue=>{:issue_geographies=>[{:datum=>"DATUM"}]} }
      end
      it "create issue_geographies" do
        assigns[:issue].issue_geographies.should be_present
      end
    end
    describe "params[:issue][:issue_geographies] not present " do
      before do
      end
      it "return true" do
        controller.should_receive(:build_new_issue_geography_from_params).and_return(true)
        post :create, {:project_id=>project_id }
      end
    end
  end


  describe "#get_delivery_histories " do
    before do
      Issue.any_instance.stub(:visible?) {true}
      @issue = FactoryGirl.create(:issue1, :project_id=>project_id)
    end
    it "call DeliveryHistory.find_by_sql" do
      DeliveryHistory.should_receive(:find_by_sql)
      get :show, {:id=> @issue.id}
    end
  end


  describe "#get_destination_list " do
    before do
      Issue.any_instance.stub(:visible?) {true}
      @issue = FactoryGirl.create(:issue1, :project_id=>project_id)
    end
    it "get destination_list" do
      get :show, {:id=> @issue.id}
      assigns[:destination_list].should == DST_LIST['destination'][2][@issue.tracker_id] # role_id 2: # Anonymous
    end
  end


  describe "#set_issue_geography_data " do
    describe "issue_geographies blank " do
      before do
        Issue.any_instance.stub(:visible?) {true}
        @issue = FactoryGirl.create(:issue1, :project_id=>project_id)
      end
      it "set_issue_geography_data default" do
        get :show, {:id=> @issue.id}
        assigns[:points].should == [{"points" => [MAP_VALUES['ishi_lat'], MAP_VALUES['ishi_lon']],  "remarks" => MAP_VALUES['ishi_addr']}]
        assigns[:lines].should == []
        assigns[:polygons].should == []
      end
    end
    describe "issue_geographies not blank " do
      before do
        Issue.any_instance.stub(:visible?) {true}
        @issue = FactoryGirl.create(:issue1, :project_id=>project_id)
        @issue_geography = FactoryGirl.create(:issue_geography1, :issue_id=>@issue.id)
        controller.stub(:set_points) {"points_array"}
        controller.stub(:set_lines) {"lines_array"}
        controller.stub(:set_polygons) {"polygons_array"}
      end
      it "set_issue_geography_data from table" do
        get :show, {:id=> @issue.id}

        assigns[:points].should == "points_array"
        assigns[:lines].should == "lines_array"
        assigns[:polygons].should == "polygons_array"
      end
    end
  end


  describe "#set_points " do
    before do
      Issue.any_instance.stub(:visible?) {true}
      @issue = FactoryGirl.create(:issue1, :project_id=>project_id)
      @issue_geography = FactoryGirl.create(:issue_geography1, :issue_id=>@issue.id)
    end
    it "return points data" do
      ret = controller.__send__(:set_points, [@issue_geography])
      
      ret.should == [
                      {"points"=>[2.0, 1.0], 
                      "remarks"=>@issue_geography.remarks}
                    ]
    end
  end


  describe "#set_lines " do
    before do
      Issue.any_instance.stub(:visible?) {true}
      @issue = FactoryGirl.create(:issue1, :project_id=>project_id)
      @issue_geography = FactoryGirl.create(:issue_geography1, :issue_id=>@issue.id)
    end
    it "return liness data" do
      ret = controller.__send__(:set_lines, [@issue_geography])
      
      ret.should == [
                      {"points"=>[[6.0, 5.0], [5.0, 4.0], [4.0, 3.0], [3.0, 2.0]],
                      "remarks"=>@issue_geography.remarks}
                    ]
    end
  end


  describe "#set_lines " do
    before do
      Issue.any_instance.stub(:visible?) {true}
      @issue = FactoryGirl.create(:issue1, :project_id=>project_id)
      @issue_geography = FactoryGirl.create(:issue_geography1, :issue_id=>@issue.id)
    end
    it "return polygons data" do
      ret = controller.__send__(:set_polygons, [@issue_geography])
      
      ret.should == [
                      {"points"=>[[6.0, 7.0], [7.0, 6.0], [7.0, 7.0], [6.0, 6.0]], 
                      "remarks"=>@issue_geography.remarks}
                    ]
    end
  end


  describe "#set_geo " do
    before do
      Issue.any_instance.stub(:visible?) {true}
      @issue = FactoryGirl.create(:issue1, :project_id=>project_id)
      @issue_geography = FactoryGirl.create(:issue_geography1, :issue_id=>@issue.id)
    end
    describe "points flag true " do
      it "return 1 point (points) data" do
        ret = controller.__send__(:set_geo, @issue_geography, [2.0,1.0], true)
        
        ret.should ==  {"points"=>[2.0, 1.0], 
                       "remarks"=>@issue_geography.remarks}
      end
    end
    describe "points flag nil " do
      it "return 2 points pair (lines,polygons) data" do
        ret = controller.__send__(:set_geo, @issue_geography, [6.0, 5.0, 5.0, 4.0, 4.0, 3.0, 3.0, 2.0])
        
        ret.should ==  {"points"=>[[6.0, 5.0], [5.0, 4.0], [4.0, 3.0], [3.0, 2.0]], 
                       "remarks"=>@issue_geography.remarks}
      end
    end
  end


  describe "#get_constant_data " do
    before do
      Issue.any_instance.stub(:visible?) {true}
      @issue = FactoryGirl.create(:issue1, :project_id=>project_id)
    end
    it "get @waring_const_cause, @waring_const_apply from cache" do
      get :show, {:id=> @issue.id}
      
      assigns[:waring_const_cause].should == "ret_waring_const_cause"
      assigns[:waring_const_apply].should == "ret_waring_const_apply"
    end
  end


end

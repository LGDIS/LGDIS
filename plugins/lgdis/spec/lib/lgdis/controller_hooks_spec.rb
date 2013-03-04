# -*- coding:utf-8 -*-
require 'spec_helper'

describe Lgdis::ControllerHooks do
  before do
    @hooks = Lgdis::ControllerHooks.__send__(:new)
  end
  
  describe "#controller_issues_new_after_save " do
    describe "auto_launch = 1 " do
      before do
        @context = {:params=>{:issue=> {:auto_launch=>"1"}}}
      end
      it "call create_project" do
        @hooks.should_receive(:create_project).with(@context)
        @hooks.controller_issues_new_after_save(@context)
      end
    end
    describe "auto_launch = 2 " do
      before do
        @context = {:params=>{:issue=> {:auto_launch=>"2"}}}
      end
      it "not call create_project" do
        @hooks.should_not_receive(:create_project)
        @hooks.controller_issues_new_after_save(@context)
      end
    end
    describe "auto_send = 1 " do
      before do
        @context = {:params=>{:issue=> {:auto_send=>"1"}}}
      end
      it "call deliver_issue" do
        @hooks.should_receive(:deliver_issue).with(@context)
        @hooks.controller_issues_new_after_save(@context)
      end
    end
    describe "auto_send = 2 " do
      before do
        @context = {:params=>{:issue=> {:auto_send=>"2"}}}
      end
      it "not call deliver_issue" do
        @hooks.should_not_receive(:deliver_issue)
        @hooks.controller_issues_new_after_save(@context)
      end
    end
  end
  
  
  describe "#view_account_login_bottom " do
    before do
      @controller = SheltersController.new
      @context = {:controller=>@controller}
      
      @controller.should_receive(:render_to_string).with({:partial => "account/view_account_login_bottom", :locals => @context})
      
    end
    it "call controller's render_to_string" do
      @hooks.__send__(:view_account_login_bottom, @context)
    end
  end
  
  
  describe "#create_project " do
    before do
      @context = {:issue=>mock_model(Issue)}
    end
    it "call create_project" do
      @hooks.should_receive(:new_project_name).with(@context[:issue]).and_return("project_name")
      Project.any_instance.should_receive(:save!)
      @hooks.__send__(:create_project, @context)
    end
  end
  
  
  describe "#new_project_name " do
    describe "issue.xml_head_reportdatetime present, issue.xml_head_title present " do
      before do
        @rep_time = Time.parse("2013/02/02 12:12:12")
        @cre_time = Time.parse("2013/02/03 13:13:13")
        @issue = mock_model(Issue)
        @issue.stub(:xml_head_reportdatetime) {@rep_time}
        @issue.stub(:xml_head_title) {"xml_head_title"}
        @issue.stub(:created_on) {@cre_time}
        @context = {:issue=>@issue}
      end
      it "return xml_head_reportdatetime, xml_head_title" do
        return_name = @hooks.__send__(:new_project_name, @issue)
        return_name.should == @rep_time.strftime("%Y/%m/%d %H:%M") + " xml_head_title"
      end
    end
    describe "issue.xml_head_reportdatetime not present, issue.xml_head_title present " do
      before do
        @cre_time = Time.parse("2013/02/03 13:13:13")
        @issue = mock_model(Issue)
        @issue.stub(:xml_head_reportdatetime) {nil}
        @issue.stub(:xml_head_title) {"xml_head_title"}
        @issue.stub(:created_on) {@cre_time}
        @context = {:issue=>@issue}
      end
      it "return xml_head_title only" do
        return_name = @hooks.__send__(:new_project_name, @issue)
        return_name.should == "xml_head_title"
      end
    end
    describe "issue.xml_head_reportdatetime not present, issue.xml_head_title not present " do
      before do
        @cre_time = Time.parse("2013/02/03 13:13:13")
        @issue = mock_model(Issue)
        @issue.stub(:xml_head_reportdatetime) {nil}
        @issue.stub(:xml_head_title) {nil}
        @issue.stub(:created_on) {@cre_time}
        @context = {:issue=>@issue}
      end
      it "return created_on" do
        return_name = @hooks.__send__(:new_project_name, @issue)
        return_name.should == @cre_time.strftime("%Y/%m/%d %H:%M")
      end
    end
  end
  
  
  describe "#deliver_issue " do
    describe "target is not blank " do
      before do
        dh_test = "deliveryhistory"
        @issue = mock_model(Issue)
        @issue.stub(:id).and_return("1")
        @issue.stub(:project_id).and_return("5")
        @issue.should_receive(:deliver).with(dh_test, 'runtime').and_return("OK")
        @context = {:issue=>@issue, :params=>{:issue=>{:send_target=>"send_target_exist"}}}
        DeliveryHistory.should_receive(:create!).and_return(dh_test)
      end
      it "call deliver_issue" do
        lambda{@hooks.__send__(:deliver_issue, @context)}.should_not raise_error
      end
    end
    describe "raise error " do
      before do
        dh_test = "deliveryhistory"
        @issue = mock_model(Issue)
        @issue.stub(:id).and_return("1")
        @issue.stub(:project_id).and_return("5")
        @context = {:issue=>@issue, :params=>{:issue=>{:send_target=>nil}}}
      end
      it "raise error" do
        lambda{@hooks.__send__(:deliver_issue, @context)}.should raise_error("配備番号が未設定です")
      end
    end
  end
  
  
end

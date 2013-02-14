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
        @issue = mock_model(Issue)
        @issue.stub(:xml_head_reportdatetime) {"2013/02/02 12:12:12"}
        @issue.stub(:xml_head_title) {"xml_head_title"}
        @issue.stub(:created_on) {"2013/02/03 13:13:13"}
        @context = {:issue=>@issue}
      end
      it "return xml_head_reportdatetime, xml_head_title" do
        return_name = @hooks.__send__(:new_project_name, @issue)
        return_name.should == "02/02/2013 09:12 pm xml_head_title"
        p return_name
      end
    end
    describe "issue.xml_head_reportdatetime not present, issue.xml_head_title present " do
      before do
        @issue = mock_model(Issue)
        @issue.stub(:xml_head_reportdatetime) {nil}
        @issue.stub(:xml_head_title) {"xml_head_title"}
        @issue.stub(:created_on) {"2013/02/03 13:13:13"}
        @context = {:issue=>@issue}
      end
      it "return xml_head_title only" do
        return_name = @hooks.__send__(:new_project_name, @issue)
        return_name.should == "xml_head_title"
        p return_name
      end
    end
    describe "issue.xml_head_reportdatetime not present, issue.xml_head_title not present " do
      before do
        @issue = mock_model(Issue)
        @issue.stub(:xml_head_reportdatetime) {nil}
        @issue.stub(:xml_head_title) {nil}
        @issue.stub(:created_on) {"2013/02/03 13:13:13"}
        @context = {:issue=>@issue}
      end
      it "call create_project" do
        return_name = @hooks.__send__(:new_project_name, @issue)
        return_name.should == "02/03/2013 10:13 pm"
        p return_name
      end
    end
  end
  
  
  describe "#deliver_issue " do
    before do
      @context = {:issue=>mock_model(Issue)}
    end
    it "call deliver_issue" do
      pending("TODO多数の為保留") # TODO: 
    end
  end
  
  
end

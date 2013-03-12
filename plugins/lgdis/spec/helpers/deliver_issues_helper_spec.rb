# -*- coding:utf-8 -*-
require 'spec_helper'
include DeliverIssuesHelper

describe DeliverIssuesHelper do
  
  describe "#check_admin" do
    describe "admin user" do
      before do
        @issue = Issue.new
        @role_3 = Role.find(3) # 3:管理者
        User.any_instance.stub(:roles_for_project) {[@role_3]}
      end
      it "return true" do
        DeliverIssuesHelper.check_admin(@issue).should be_true
      end
    end
    describe "not admin user" do
      before do
        @issue = Issue.new
        @role_2 = Role.find(2) # 2:"Anonymous" 
        User.any_instance.stub(:roles_for_project) {[@role_2]}
      end
      it "return false" do
        DeliverIssuesHelper.check_admin(@issue).should be_false
      end
    end
  end
  
  
end

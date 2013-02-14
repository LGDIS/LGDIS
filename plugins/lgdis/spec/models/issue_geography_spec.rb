# -*- coding:utf-8 -*-
require 'spec_helper'
describe IssueGeography do
  describe "Validation OK" do
    before do
      @issue_geography = IssueGeography.new
      
      @issue_geography.issue_id = 1
      @issue_geography.datum    = 'D'*10
      @issue_geography.location = 'L'*100
      @issue_geography.point    = '(1,1)'
      @issue_geography.line     = '((2,2),(3,3),(4,4),(5,5))'
      @issue_geography.polygon  = '((6,6),(7,7),(6,7),(7,6))'
      @issue_geography.remarks  = 'R'*255
    end
    it "save success" do
      @issue_geography.save.should be_true
    end
  end
  
  describe "Validation datum length 10 over" do
    before do
      @issue_geography = IssueGeography.new
      
      @issue_geography.issue_id = 1
      @issue_geography.datum    = 'D'*11
      @issue_geography.location = 'L'*100
      @issue_geography.point    = '(1,1)'
      @issue_geography.line     = '((2,2),(3,3),(4,4),(5,5))'
      @issue_geography.polygon  = '((6,6),(7,7),(6,7),(7,6))'
      @issue_geography.remarks  = 'R'*255
    end
    it "save failure" do
      @issue_geography.save.should be_false
    end
  end
  
  describe "Validation location length 100 over" do
    before do
      @issue_geography = IssueGeography.new
      
      @issue_geography.issue_id = 1
      @issue_geography.datum    = 'D'*10
      @issue_geography.location = 'L'*101
      @issue_geography.point    = '(1,1)'
      @issue_geography.line     = '((2,2),(3,3),(4,4),(5,5))'
      @issue_geography.polygon  = '((6,6),(7,7),(6,7),(7,6))'
      @issue_geography.remarks  = 'R'*255
    end
    it "save failure" do
      @issue_geography.save.should be_false
    end
  end
  
  describe "Validation remarks length 255 over" do
    before do
      @issue_geography = IssueGeography.new
      
      @issue_geography.issue_id = 1
      @issue_geography.datum    = 'D'*10
      @issue_geography.location = 'L'*100
      @issue_geography.point    = '(1,1)'
      @issue_geography.line     = '((2,2),(3,3),(4,4),(5,5))'
      @issue_geography.polygon  = '((6,6),(7,7),(6,7),(7,6))'
      @issue_geography.remarks  = 'R'*256
    end
    it "save failure" do
      @issue_geography.save.should be_false
    end
  end
  
end

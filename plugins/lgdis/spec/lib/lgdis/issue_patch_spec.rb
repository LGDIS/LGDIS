# -*- coding:utf-8 -*-
require 'spec_helper'
describe Lgdis::IssuePatch do
  before do
    @project = FactoryGirl.build(:project1, :id => 5)
    @project.save!
    @issue = Issue.new
    @issue.id   = 1
    @issue.tracker_id   = 1
    @issue.project_id   = @project.id
    @issue.subject      = "SUBJECT"
    @issue.description  = "DESCRIPTION"
    @issue.status_id    = 1
    @issue.priority_id  = 1
    @issue.author_id    = 1
    @issue.lock_version = 1
    @issue.done_ratio   = 1
    @issue.is_private   = true

    @issue.xml_control_status           = 'A'*12
    @issue.xml_control_editorialoffice  = 'A'*50
    @issue.xml_control_publishingoffice = 'A'*100
    @issue.xml_control_cause            = 'A'*1
    @issue.xml_control_apply            = 'A'*1
    @issue.xml_head_title               = 'A'*100
    @issue.xml_head_targetdtdubious     = 'A'*8
    @issue.xml_head_targetduration      = 'A'*30
    @issue.xml_head_eventid             = 'A'*64
    @issue.xml_head_infotype            = 'A'*8
    @issue.xml_head_serial              = 'A'*8
    @issue.xml_head_infokind            = 'A'*100
    @issue.xml_head_infokindversion     = 'A'*12
    @issue.xml_head_text                = 'A'*500
  end


#  describe "Validation OK" do
#    it "save success" do
#      @issue.save.should be_true
#    end
#  end
#  
#  describe "Validation xml_control_status length 12 over" do
#    before do
#      @issue.xml_control_status           = 'A'*13
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_control_editorialoffice length 50 over" do
#    before do
#      @issue.xml_control_editorialoffice  = 'A'*51
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_control_publishingoffice length 100 over" do
#    before do
#      @issue.xml_control_publishingoffice = 'A'*101
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_control_cause length 1 over" do
#    before do
#      @issue.xml_control_cause            = 'A'*2
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_control_apply length 1 over" do
#    before do
#      @issue.xml_control_apply            = 'A'*2
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_head_title length 100 over" do
#    before do
#      @issue.xml_head_title               = 'A'*101
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_head_targetdtdubious length 8 over" do
#    before do
#      @issue.xml_head_targetdtdubious     = 'A'*9
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_head_targetduration length 30 over" do
#    before do
#      @issue.xml_head_targetduration      = 'A'*31
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_head_eventid length 64 over" do
#    before do
#      @issue.xml_head_eventid             = 'A'*65
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_control_editorialoffice length 50 over" do
#    before do
#    @issue.xml_control_editorialoffice  = 'A'*51
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_head_infotype length 8 over" do
#    before do
#      @issue.xml_head_infotype            = 'A'*9
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_head_serial length 8 over" do
#    before do
#      @issue.xml_head_serial              = 'A'*9
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_head_infokind length 100 over" do
#    before do
#      @issue.xml_head_infokind            = 'A'*101
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_head_infokindversion length 12 over" do
#    before do
#      @issue.xml_head_infokindversion     = 'A'*13
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  describe "Validation xml_head_text length 500 over" do
#    before do
#      @issue.xml_head_text                = 'A'*501
#    end
#    it "save failure" do
#      @issue.save.should be_false
#    end
#  end
#  
#  
#  describe "#copy_from_with_geographies " do
#    before do
#      @issue.save
#      @issue_geography = FactoryGirl.create(:issue_geography1, :issue_id=>@issue.id)
#    end
#    it "copy issue_geography" do
#      new_issue = Issue.new
#      new_issue.copy_from_with_geographies(@issue)
#      new_issue_geography = new_issue.issue_geographies[0]
#      
#      new_issue.tracker_id.should   == @issue.tracker_id
#      new_issue.project_id.should   == @issue.project_id
#      new_issue.subject.should      == @issue.subject
#      new_issue.description.should  == @issue.description
#      new_issue.status_id.should    == @issue.status_id
#      new_issue.priority_id.should  == @issue.priority_id
#      new_issue.author_id.should_not== @issue.author_id
#      new_issue.lock_version.should == @issue.lock_version
#      new_issue.done_ratio.should   == @issue.done_ratio
#      new_issue.is_private.should   == @issue.is_private
#      
#      new_issue_geography.datum.should == @issue_geography.datum
#      new_issue_geography.location.should == @issue_geography.location
#      new_issue_geography.point.should == @issue_geography.point
#      new_issue_geography.line.should == @issue_geography.line
#      new_issue_geography.polygon.should == @issue_geography.polygon
#      new_issue_geography.remarks.should == @issue_geography.remarks
#    end
#  end
#  
#  describe "#create_commons_msg " do
#    before do
#    end
#    it "" do
#      pending("未実装の為、保留")
#    end
#  end
  
  
  describe "#create_twitter_msg " do
    before do
      @issue.save
#      @cv = CustomValue.where(:customized_id =>@issue.id, :custom_field_id=>4)[0] #  DST_LIST['custom_field_delivery']['summary']=4
#      @cv.value ="twitter_msg"
#      @cv.save
#      p CustomValue.find(:all)
#      p CustomValue.find(:all).detect {|v| v.custom_field_id == 4 }.try(:value)
      @return_value = "return_value"
      @issue.should_receive(:name_in_custom_field_value).with(DST_LIST['custom_field_delivery']['summary']).and_return(@return_value)

    end
    it "get summary" do
      @issue.create_twitter_msg.should == @return_value
    end
  end
  
  
#  describe "#create_facebook_msg " do
#    before do
#      @issue.save
#    end
#    it "get summary" do
#      @issue.create_facebook_msg.should == @issue.description
#    end
#  end
#  
#  
#  describe "#create_smtp_msg " do
#    # TODO: mailing_list の選択基準未決(手動 & 自動)の為ロジックが未実装
#    before do
#      @issue.save
#      Issue.any_instance.stub(:add_url_and_training) {"add_url_and_training_text"}
#    end
#    it "get summary" do
#      summary = @issue.create_smtp_msg
#      # TODO: Hashのキー名が変わる可能性あり
#      p summary
#      summary["mailing_list_name"].should == DST_LIST['mailing_list']['local_government_officer_mail']
#      summary["title"].should == @issue.mail_subject
#      summary["message"].should == "add_url_and_training_text"
#    end
#  end
#  
#  
#  describe "#add_url_and_training " do
#    before do
#      @issue.save
#    end
#    describe "DST_LIST['smtp']['target_num'] specified " do
#      it "return DST_LIST['lgdsf_url']" do
#        summary = @issue.add_url_and_training(@issue.description, 2) # DST_LIST['smtp']['target_num']に2(自治体職員向けメール)が指定されている
#        summary.should == DST_LIST['lgdsf_url'] + "\n" + @issue.description
#      end
#    end
#    describe "DST_LIST['smtp']['target_num'] not specified " do
#      it "return DST_LIST['disaster_portal_url']" do
#        summary = @issue.add_url_and_training(@issue.description, 3) 
#        summary.should == DST_LIST['disaster_portal_url'] + "\n" + @issue.description
#      end
#    end
#    describe "training_mode specified " do
#      before do
#        @project6 = FactoryGirl.build(:project1, :id => 6)
#        @project6.save!
#        @issue.project_id = 6
#      end
#      it "return add training mode prefix" do
#        summary = @issue.add_url_and_training(@issue.description, 2) # DST_LIST['smtp']['target_num']に2(自治体職員向けメール)が指定されている
#        summary.should == "【災害訓練】" + "\n" + DST_LIST['lgdsf_url'] + "\n" + @issue.description
#      end
#    end
#  end
#  
#  
#  describe "#create_commons_msg " do
#    before do
##      @issue.save
##      @cv = CustomValue.where(:customized_id =>@issue.id, :custom_field_id=>10)[0] # DST_LIST['custom_field_delivery']['target_date']が10
##      @cv.value ="2012/12/12 "
##      @cv.save
##      @cv = CustomValue.where(:customized_id =>@issue.id, :custom_field_id=>11)[0] # DST_LIST['custom_field_delivery']['target_time']が11
##      @cv.value ="12:12:12"
##      @cv.save
##      p @cv
#    end
#    describe "edition_mng ? " do
#      before do
#      end
#      it "" do
#        #doc = @issue.create_commons_msg
#        pending("詳細未定の為、保留")
#      end
#    end
#  end
#  
#  
#  describe "#create_commmons_area_mail_body " do
#    it "" do
#      pending("未実装の為、保留")
#    end
#  end
  
  
end

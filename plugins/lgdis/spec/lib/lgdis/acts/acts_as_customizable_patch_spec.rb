# -*- coding:utf-8 -*-
require 'spec_helper'

describe Lgdis:: Acts::DatetimeSeparable do
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
    @issue.priority_id  = 2
    @issue.author_id    = 1
    @issue.lock_version = 0
    @issue.done_ratio   = 1
    @issue.is_private   = false

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
  describe "#custom_field_values_with_multipul_default_values " do
    before do
      @issue.save

      @cfv1 = CustomFieldValue.new
      @cfv1.value = [[1,2,3]]
      @cfv2 = CustomFieldValue.new
      @cfv2.value = [[2,4,6]]
      @cfv3 = CustomFieldValue.new
      @cfv3.value = [[3,6,9]]
      @issue.should_receive(:custom_field_values_without_multipul_default_values).and_return([@cfv1,@cfv2,@cfv3])
    end
    it "cancel array nest" do
      ret_array = @issue.custom_field_values_with_multipul_default_values
      ret_array[0].value.should == [1, 2, 3]
      ret_array[1].value.should == [2, 4, 6]
      ret_array[2].value.should == [3, 6, 9]
    end
  end
  
  
  describe "#name_in_custom_field_value " do
    describe "custom_field.field_format is not 'list' " do
      before do
        @issue.save
        @cv = CustomValue.where(:customized_id=>@issue.id, :custom_field_id=>8,).first
        @cv.value = "123:名称"
        @cv.save!
      end
      it "return not change value" do
        ret = Issue.find(@issue.id).name_in_custom_field_value(8) # 8:情報の発表日時 フォーマットは date
        ret.should == @cv.value
      end
    end
    describe "custom_field.field_format is 'list', value is Array " do
      before do
        @issue.save
        CustomFieldValue.any_instance.stub(:value) {["123:名称１", "456:名称２", "789:名称３"]}
      end
      it "return splited value" do
        ret = Issue.find(@issue.id).name_in_custom_field_value(14) # 14:情報の識別区分 フォーマットは list
        ret.should == ["名称１", "名称２", "名称３"]
      end
    end
    describe "custom_field.field_format is 'list', value is Strng " do
      before do
        @issue.save
        @cv = CustomValue.where(:customized_id=>@issue.id, :custom_field_id=>14,).first
        @cv.value = "123:名称１"
        @cv.save!
      end
      it "return splited value" do
        ret = Issue.find(@issue.id).name_in_custom_field_value(14) # 14:情報の識別区分 フォーマットは list
        ret.should == "名称１"
      end
    end
    describe "custom_field.field_format is 'list', value is not Array not String " do
      before do
        @issue.save
        CustomFieldValue.any_instance.stub(:value) {123}
      end
      it "return splited value" do
        ret = Issue.find(@issue.id).name_in_custom_field_value(14) # 14:情報の識別区分 フォーマットは list
        ret.should == 123
      end
    end
    describe "custom_field.field_format is 'list', value is not contain ':' " do
      before do
        @issue.save
        @cv = CustomValue.where(:customized_id=>@issue.id, :custom_field_id=>14,).first
        @cv.value = "value"
        @cv.save!
      end
      it "return splited value" do
        ret = Issue.find(@issue.id).name_in_custom_field_value(14) # 14:情報の識別区分 フォーマットは list
        ret.should == @cv.value
      end
    end
  end
  describe "#split_custom_field_value " do
    describe "contain ':' " do
      before do
        @issue.save
      end
      it "return split value array" do
        ret = @issue.__send__(:split_custom_field_value, "aaa:bbb")
        ret.should == ["aaa", "bbb"]
      end
    end
    describe "not contain ':' " do
      before do
        @issue.save
      end
      it "return original value array" do
        ret = @issue.__send__(:split_custom_field_value, "aaabbb")
        ret.should == ["aaabbb", "aaabbb"]

      end
    end
  end
  
  
end

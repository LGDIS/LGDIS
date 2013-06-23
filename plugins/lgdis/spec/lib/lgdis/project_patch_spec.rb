# -*- coding:utf-8 -*-
require 'spec_helper'
describe Lgdis::ProjectPatch do
  before do
    @project = FactoryGirl.build(:project1, :id => 5)
  end
  describe "Validation identifier validates_presence_of " do
    before do
      @project.save
    end
    it "validate disabled, save success" do
      @project.save.should be_true
    end
  end

  describe "Validation identifier validates_uniqueness_of " do
    before do
      @project.identifier = "test_identifier" # ここで指定しても実際はset_identifer採番された値となる
      @project.save
      @project2 = FactoryGirl.build(:project1, :id => 2)
      @project2.identifier = @project.identifier
    end
    it "validate disabled, save success" do
      @project2.save.should be_true
    end
  end
  
  describe "Validation identifier length 100 over " do
    before do
      @project.identifier = "I"*101
      @project.save
    end
    it "validate disabled, save success" do
      @project.save.should be_true
    end
  end

  describe "Validation identifier validates_format_of /^(?!\d+$)[a-z0-9\-_]*$/ " do
    before do
      @project.identifier = "abc***def"
      @project.save
    end
    it "validate disabled, save success" do
      @project.save.should be_true
    end
  end

  describe "Validation identifier validates_exclusion_of in new " do
    before do
      @project.identifier = "abc_new_def"
      @project.save
    end
    it "validate disabled, save success" do
      @project.save.should be_true
    end
  end


  describe "#set_identifer " do
    it "set identifier" do
      @project.connection.stub(:select_value) {"1234567890"}
      @project.set_identifer
      @project.identifier.should == "I04202000001234567890"
    end
    it "call by before_create once" do
      @project.should_receive(:set_identifer)
      @project.save.should be_true
    end
  end


  describe "#identifier_frozen_with_always_freeze? " do
    describe "identifier_defrosted true" do
      it "return true" do
        # 初期状態は@identifier_defrostedはfalse
        @project.should_not_receive(:identifier_frozen_without_always_freeze?)
        @project.identifier_frozen_with_always_freeze?.should be_true
      end
    end

    describe "identifier_defrosted false" do
      it "call identifier_frozen_without_always_freeze?" do
        @project.set_identifer #set_identiferを実行すると@identifier_defrostedがtrueになる
        @project.should_receive(:identifier_frozen_without_always_freeze?)
        @project.identifier_frozen_with_always_freeze?
      end
    end
  end


  describe "#initialize_with_identifier_customize " do
    it "set identifier at initialize" do
      @project.identifier.should == "システムで自動設定されます"
    end
  end


  describe "#disaster_code " do
    it "get disaster_code" do
      @project.save
      @project.disaster_code.should == @project.identifier.delete("I")
    end
  end


  
end

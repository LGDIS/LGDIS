# -*- coding:utf-8 -*-
require 'spec_helper'

# 表示向け変更メソッドで使用する定数
DATUM_JGD = "世界測地系"
DATUM_TKY = "日本測地系"

describe IssueGeography do
  describe "Validation OK" do
    describe "Validation" do
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
  
  
  describe "#location_for_map" do
    describe "location present " do
      before do
        @issue_geography = IssueGeography.new
        @issue_geography.issue_id = 1
        @issue_geography.datum    = 'DATUM'
        @issue_geography.location = 'LOCATION'
        @issue_geography.point    = '(1,1)'
        @issue_geography.line     = '((2,2),(3,3),(4,4),(5,5))'
        @issue_geography.polygon  = '((6,6),(7,7),(6,7),(7,6))'
        @issue_geography.remarks  = 'REMARKS'
        @issue_geography.save!
      end
      it "return hash contain location,remarks" do
        @issue_geography.location_for_map.should == {"location" => @issue_geography.location, "remarks" => @issue_geography.remarks}
      end
    end
    describe "location not present " do
      before do
        @issue_geography = IssueGeography.new
        @issue_geography.issue_id = 1
        @issue_geography.datum    = 'DATUM'
        @issue_geography.location = nil
        @issue_geography.point    = '(1,1)'
        @issue_geography.line     = '((2,2),(3,3),(4,4),(5,5))'
        @issue_geography.polygon  = '((6,6),(7,7),(6,7),(7,6))'
        @issue_geography.remarks  = 'REMARKS'
        @issue_geography.save!
      end
      it "return nil" do
        @issue_geography.location_for_map.should == nil
      end
    end
  end
  
  
  describe "#point_for_map" do
    describe "point present " do
      before do
        @issue_geography = IssueGeography.new
        @issue_geography.issue_id = 1
        @issue_geography.datum    = DATUM_TKY
        @issue_geography.location = 'LOCATION'
        @issue_geography.point    = '(1,2)'
        @issue_geography.line     = '((2,2),(3,3),(4,4),(5,5))'
        @issue_geography.polygon  = '((6,6),(7,7),(6,7),(7,6))'
        @issue_geography.remarks  = 'REMARKS'
        @issue_geography.save!
        IssueGeography.should_receive(:yx_to_xy_with_conv_datum)
                      .with(@issue_geography.point, @issue_geography.datum, DATUM_JGD)
                      .and_return("conv_point")
        @issue_geography.should_receive(:points_hash_for_map).with("conv_point").and_return("point_hash")
      end
      it "return point hash" do
        @issue_geography.point_for_map(DATUM_JGD).should == "point_hash"
      end
    end
    describe "point not present " do
      before do
        @issue_geography = IssueGeography.new
        @issue_geography.issue_id = 1
        @issue_geography.datum    = 'DATUM'
        @issue_geography.location = 'LOCATION'
        @issue_geography.point    = nil
        @issue_geography.line     = '((2,2),(3,3),(4,4),(5,5))'
        @issue_geography.polygon  = '((6,6),(7,7),(6,7),(7,6))'
        @issue_geography.remarks  = 'REMARKS'
        @issue_geography.save!
      end
      it "return nil" do
        @issue_geography.point_for_map(DATUM_JGD).should == nil
      end
    end
  end
  
  
  describe "#line_for_map" do
    describe "line present " do
      before do
        @issue_geography = IssueGeography.new
        @issue_geography.issue_id = 1
        @issue_geography.datum    = DATUM_TKY
        @issue_geography.location = 'LOCATION'
        @issue_geography.point    = '(1,2)'
        @issue_geography.line     = '((2,2),(3,3),(4,4),(5,5))'
        @issue_geography.polygon  = '((6,6),(7,7),(6,7),(7,6))'
        @issue_geography.remarks  = 'REMARKS'
        @issue_geography.save!
        IssueGeography.should_receive(:yx_to_xy_with_conv_datum)
                      .with(@issue_geography.line, @issue_geography.datum, DATUM_JGD)
                      .and_return("conv_points")
        @issue_geography.should_receive(:points_hash_for_map).with("conv_points").and_return("points_hash")
      end
      it "return line hash" do
        @issue_geography.line_for_map(DATUM_JGD).should == "points_hash"
      end
    end
    describe "line not present " do
      before do
        @issue_geography = IssueGeography.new
        @issue_geography.issue_id = 1
        @issue_geography.datum    = 'DATUM'
        @issue_geography.location = 'LOCATION'
        @issue_geography.point    = '(1,2)'
        @issue_geography.line     = nil
        @issue_geography.polygon  = '((6,6),(7,7),(6,7),(7,6))'
        @issue_geography.remarks  = 'REMARKS'
        @issue_geography.save!
      end
      it "return nil" do
        @issue_geography.line_for_map(DATUM_JGD).should == nil
      end
    end
  end
  
  
  describe "#polygon_for_map" do
    describe "polygon present " do
      before do
        @issue_geography = IssueGeography.new
        @issue_geography.issue_id = 1
        @issue_geography.datum    = DATUM_TKY
        @issue_geography.location = 'LOCATION'
        @issue_geography.point    = '(1,2)'
        @issue_geography.line     = '((2,2),(3,3),(4,4),(5,5))'
        @issue_geography.polygon  = '((6,6),(7,7),(6,7),(7,6))'
        @issue_geography.remarks  = 'REMARKS'
        @issue_geography.save!
        IssueGeography.should_receive(:yx_to_xy_with_conv_datum)
                      .with(@issue_geography.polygon, @issue_geography.datum, DATUM_JGD)
                      .and_return("conv_points")
        @issue_geography.should_receive(:points_hash_for_map).with("conv_points").and_return("points_hash")
      end
      it "return polygon hash" do
        @issue_geography.polygon_for_map(DATUM_JGD).should == "points_hash"
      end
    end
    describe "polygon not present " do
      before do
        @issue_geography = IssueGeography.new
        @issue_geography.issue_id = 1
        @issue_geography.datum    = 'DATUM'
        @issue_geography.location = 'LOCATION'
        @issue_geography.point    = '(1,2)'
        @issue_geography.line     = '((2,2),(3,3),(4,4),(5,5))'
        @issue_geography.polygon  = nil
        @issue_geography.remarks  = 'REMARKS'
        @issue_geography.save!
      end
      it "return nil" do
        @issue_geography.polygon_for_map(DATUM_JGD).should == nil
      end
    end
  end
  
  
  describe "#yx_to_xy_with_conv_datum" do
    describe "jgd2tky " do
      before do
        DatumConv.should_receive(:jgd2tky).exactly(2)
      end
      it "convert DATUM_JGD to DATUM_TKY" do
        IssueGeography.yx_to_xy_with_conv_datum("((1,2),(3,4))", DATUM_JGD, DATUM_TKY)
      end
    end
    describe "tky2jgd " do
      before do
        DatumConv.should_receive(:tky2jgd).exactly(2)
      end
      it "convert DATUM_TKY to DATUM_JGD" do
        IssueGeography.yx_to_xy_with_conv_datum("((1,2),(3,4))", DATUM_TKY, DATUM_JGD)
      end
    end
    describe "same datum " do
      before do
        DatumConv.should_not_receive(:jgd2tky)
        DatumConv.should_not_receive(:tky2jgd)
      end
      it "not convert " do
        IssueGeography.yx_to_xy_with_conv_datum("((1,2),(3,4))", DATUM_TKY, DATUM_TKY)
      end
    end
    describe "content nil" do
      before do
      end
      it "return nil " do
        IssueGeography.yx_to_xy_with_conv_datum(nil, DATUM_TKY, DATUM_TKY).should be_nil
      end
    end
    describe "undefined from_datum " do
      before do
        DatumConv.should_receive(:jgd2tky).exactly(2)
      end
      it "convert from DATUM_JGD" do
        IssueGeography.yx_to_xy_with_conv_datum("((1,2),(3,4))", "異常測地系", DATUM_TKY)
      end
    end
    describe "undefined to_datum  " do
      before do
      end
      it "raise error" do
        lambda{IssueGeography.yx_to_xy_with_conv_datum("((1,2),(3,4))", DATUM_TKY, "異常測地系")}.should raise_error("指定された測地系は許容できません。")
      end
    end
  end
  
  
  describe "#points_hash_for_map " do
    before do
      @issue_geography = IssueGeography.new
      @issue_geography.issue_id = 1
      @issue_geography.datum    = 'DATUM'
      @issue_geography.location = 'LOCATION'
      @issue_geography.point    = '(1,2)'
      @issue_geography.line     = '((2,2),(3,3),(4,4),(5,5))'
      @issue_geography.polygon  = '((6,6),(7,7),(6,7),(7,6))'
      @issue_geography.remarks  = 'REMARKS'
      @issue_geography.save!
      
      @points = "POINTS"
    end
    it "convert DATUM_JGD to DATUM_TKY" do
      @issue_geography.__send__(:points_hash_for_map, @points).should == {"points"=>@points, "remarks"=>@issue_geography.remarks}
    end
  end


end

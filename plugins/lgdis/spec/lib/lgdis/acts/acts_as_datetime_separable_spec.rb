# -*- coding:utf-8 -*-
require 'spec_helper'

describe Lgdis:: Acts::DatetimeSeparable do
  # ActiveRecord::BaseにincludeされるのでShelterクラスで動作を確認する
  CONST = Constant::hash_for_table(Shelter.table_name).freeze
  before do
    User.current = nil # 一度設定されたcurrent_userが保持されるのでここでnilに設定
    @project = FactoryGirl.build(:project1, :id => 5)
    @project.save!
    @issue = FactoryGirl.create(:issue1, :project_id=>@project.id)
    @issue.save!
    
    @shelter = Shelter.new
    @shelter.id                                    = 1
    @shelter.name                                  = "避難所名" 
    @shelter.name_kana                             = "ひなんじょめいかな"
    @shelter.area                                  = "避難所の地区"
    @shelter.address                               = "避難所の住所"
    @shelter.phone                                 = "012345678901"
    @shelter.fax                                   = "012345678902"
#    @shelter.e_mail                               
#    @shelter.person_responsible                   
    @shelter.shelter_type                          = "1" # 避難所
#    @shelter.shelter_type_detail                  
    @shelter.shelter_sort                          = "3" # 閉鎖
    @shelter.opened_at                             = "2012-12-13 14:15:16"
    @shelter.closed_at                             = "2013-12-13 14:15:16"
    @shelter.capacity                              = 200
    @shelter.status                                = "2" # 混雑
    @shelter.head_count                            = 123
    @shelter.head_count_voluntary                  = 1234
    @shelter.households                            = 456
    @shelter.households_voluntary                  = 4567
    @shelter.checked_at                            = "2014-12-13 14:15:16"
    @shelter.shelter_code                          = "1"
    @shelter.manager_code                          = "MAN_CODE"
    @shelter.manager_name                          = "MANAGER_NAME"
#    @shelter.manager_another_name                 
    @shelter.reported_at                           = "2011-12-13 14:15:16"
    @shelter.building_damage_info                  = "建物被害状況"
    @shelter.electric_infra_damage_info            = "電力被害状況"
    @shelter.communication_infra_damage_info       = "通信手段被害状況"
    @shelter.other_damage_info                     = "その他の被害"
    @shelter.usable_flag                           = "1" # 可
    @shelter.openable_flag                         = "0" # 不可
    @shelter.injury_count                          = 789
    @shelter.upper_care_level_three_count          = 10
    @shelter.elderly_alone_count                   = 20
    @shelter.elderly_couple_count                  = 30
    @shelter.bedridden_elderly_count               = 40
    @shelter.elderly_dementia_count                = 50
    @shelter.rehabilitation_certificate_count      = 60
    @shelter.physical_disability_certificate_count = 70
    @shelter.note                                  = "避難所備考"
#    @shelter.deleted_at                           
#    @shelter.created_at                           
#    @shelter.updated_at                           
  end

  describe "#acts_as_datetime_separable " do
    describe "params present " do
      it "call datetime_separable_initialize" do
        columns = "columns"
        IssueGeography.should_receive(:datetime_separable_initialize).with([columns])
        
        IssueGeography.acts_as_datetime_separable(columns) 
      end
    end
    describe "params not present " do
      it "raise error" do
        # TODO: 可変長引数は引数なしでも[]になるので.nil?の条件にひっかからない。その為エラーはraiseされない。.blank?にするべき？
        lambda{ Constant.acts_as_datetime_separable() }.should raise_error("分割する日時フィールドの指定がありません。")
      end
    end
  end
  
  
  describe "#set_date_time_attr" do
    describe "set date, hm" do
      before do
        @attr = nil
        Shelter.any_instance.should_receive(:write_attribute).with(@attr, Time.local("2012", "12", "13", "14", "15"))
      end
      it "set datetime" do
        @shelter.__send__(:set_date_time_attr, @attr, "2012-12-13", "14:15")
      end
    end
    describe "set invalid date" do
      before do
        @attr = nil
        Shelter.any_instance.should_receive(:write_attribute).with(@attr, nil)
      end
      it "set nil" do
        @shelter.__send__(:set_date_time_attr, @attr, "2012-15-13", "14:15")
      end
    end
    describe "set invalid hm" do
      before do
        @attr = nil
        Shelter.any_instance.should_receive(:write_attribute).with(@attr, nil)
      end
      it "set nil" do
        @shelter.__send__(:set_date_time_attr, @attr, "2012-12-13", "54:15")
      end
    end
  end
  
  
  describe "#datetime_separable_initialize " do
    it "call attr_accessor_separate_datetime, validates_separate_datetime" do
      columns = "columns"
      EditionManagement.should_receive(:attr_accessor_separate_datetime)
      EditionManagement.should_receive(:validates_separate_datetime)
      EditionManagement.acts_as_datetime_separable(columns) # acts_as_datetime_separable中でattr_accessor_separate_datetimeが呼ばれる
    end
  end
  
  
  # opened_at系のみ確認する
  describe "#attr_accessor_separate_datetime" do
    describe "#opened_date" do
      describe "opened_at:nil opened_date:nil" do
        before do
          @new_shelter = Shelter.new
        end
        it "return nil" do
          @new_shelter.opened_date.should be_nil
        end
      end
      describe "opened_at:not nil opened_date:not nil" do
        before do
          @new_shelter = Shelter.new
          @new_shelter.opened_date = "2010-11-12"
        end
        it "return opened_date" do
          @new_shelter.opened_date.should == "2010-11-12"
        end
      end
      describe "opened_at:not nil opened_date:nil User.current.time_zone present" do
        before do
          @new_shelter = Shelter.new
          User.current.stub(:time_zone) {"EET"}
          @new_shelter.opened_at = "2010-11-12 03:14:15"
        end
        it "return opened_at in current user's zone time" do
          @new_shelter.opened_date.strftime("%Y-%m-%d").should == "2010-11-11" # EET(UTC+2:00)との時差で日付が前日になる
        end
      end
      describe "opened_at:utc time opened_date:nil User.current.time_zone nil" do
        before do
          @new_shelter = Shelter.new
          @new_shelter.opened_at = Time.parse("2010-11-12 03:14:15").utc # 2010-11-11 18:14:15 UTC
        end
        it "return opened_at in localtime" do
#          @new_shelter.opened_date.strftime("%Y-%m-%d").should == "2010-11-12" # localtmeでJSTの日付に戻る
          pending("DBのカラムがtimestamp without time zoneの為、値をセット時にローカルタイムゾーンであるJSTに変換されてしまい、UTCで無くなる")
        end
      end
      describe "opened_at:not nil opened_date:nil User.current.time_zone nil" do
        before do
          @new_shelter = Shelter.new
          @new_shelter.opened_at = Time.parse("2010-11-12 03:14:15")
        end
        it "return opened_at in localtime" do
          @new_shelter.opened_date.strftime("%Y-%m-%d").should == "2010-11-12" # opended_atそのままの値
        end
      end
    end
    describe "#opened_date=" do
      before do
        @new_shelter = Shelter.new
        Shelter.any_instance.should_receive(:set_date_time_attr)
      end
      it "set opened_date" do
        @new_shelter.opened_date = "2010-11-11"
        @new_shelter.opened_date.should == "2010-11-11"
      end
    end
    describe "#opened_hm" do
      describe "opened_at:nil opened_hm:nil" do
        before do
          @new_shelter = Shelter.new
        end
        it "return nil" do
          @new_shelter.opened_hm.should be_nil
        end
      end
      describe "opened_at:not nil opened_hm:not nil" do
        before do
          @new_shelter = Shelter.new
          @new_shelter.opened_hm = "13:14"
        end
        it "return opened_hm" do
          @new_shelter.opened_hm.should == "13:14"
        end
      end
      describe "opened_at:not nil opened_hm:nil User.current.time_zone present" do
        before do
          @new_shelter = Shelter.new
          User.current.stub(:time_zone) {"EET"}
          @new_shelter.opened_at = "2010-11-12 03:14:15"
          
        end
        it "return opened_at in current user's zone time" do
          @new_shelter.opened_hm.should == "20:14" # EET(UTC+2:00)との時差で日付が前日になる
        end
      end
      describe "opened_at:utc time opened_hm:nil User.current.time_zone nil" do
        before do
          @new_shelter = Shelter.new
          @new_shelter.opened_at = Time.parse("2010-11-12 03:14:15").utc # 2010-11-11 18:14:15 UTC
        end
        it "return opened_at in localtime" do
#          @new_shelter.opened_hm..should == "03:14" # localtmeでJSTの日付に戻る
          pending("DBのカラムがtimestamp without time zoneの為、値をセット時にローカルタイムゾーンであるJSTに変換されてしまい、UTCで無くなる")
        end
      end
      describe "opened_at:not nil opened_hm:nil User.current.time_zone nil" do
        before do
          @new_shelter = Shelter.new
          @new_shelter.opened_at = Time.parse("2010-11-12 03:14:15")
        end
        it "return opened_at in localtime" do
          @new_shelter.opened_hm.should == "03:14" # opended_atそのままの値
        end
      end
    end
    describe "#opened_hm=" do
      before do
        @new_shelter = Shelter.new
        Shelter.any_instance.should_receive(:set_date_time_attr)
      end
      it "set opened_hm" do
        @new_shelter.opened_hm = "12:13"
        @new_shelter.opened_hm.should == "12:13"
      end
    end
  end
  
  
  describe "#validates_separate_datetime " do
    describe "Validation opened_date date format" do
      before do
        @shelter.opened_date = "2013-13-33"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation opened_date presence unress opened_hm.blank?" do
      before do
        @shelter.opened_date = nil
        @shelter.opened_hm = "12:12"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation opened_hm time format" do
      before do
        @shelter.opened_hm = "25:60"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation opened_hm presence unress opened_date.blank?" do
      before do
        @shelter.opened_hm = nil
        @shelter.opened_date = "2012-12-12" 
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
  end

end

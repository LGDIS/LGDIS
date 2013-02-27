# -*- coding:utf-8 -*-
require 'spec_helper'

describe EvacuationAdvisory do
  CONST = Constant::hash_for_table(EvacuationAdvisory.table_name).freeze
  I18n.locale = "ja"
  before do
    User.current = nil # 一度設定されたcurrent_userが保持されるのでここでnilに設定
    @project = FactoryGirl.build(:project1, :id => 5)
    @project.save!
    @issue = FactoryGirl.create(:issue1, :project_id => @project.id)
    @issue.save!
    
    @eva = EvacuationAdvisory.new
    @eva.id                                = 1
    @eva.area                              = "避難勧告･指示名" 
    @eva.area_kana                         = "ひなんじょめいかな"
    @eva.advisory_type                     = "1"
    @eva.sort_criteria                     = "2"
    @eva.issued_at                         = "2012-12-13 14:15:16"
    @eva.lifted_at                         = "2013-12-13 14:15:16"
    @eva.issueorlift                       = "1"
    @eva.head_count                        = 123
    @eva.households                        = 456
    @eva.changed_at                        = "2014-12-13 14:15:16"
    @eva.identifier                        = "1"
    @eva.staff_no                          = "MAN_CODE"
    @eva.full_name                         = "full_name"
#    @eva.alias
    @eva.changed_at                        = "2011-12-13 14:15:16"
    @eva.remarks                           = "避難勧告･指示備考"
#    @eva.deleted_at                       
#    @eva.created_at                           
#    @eva.updated_at                           
  end
  
  describe "Validation " do
    describe "Validation OK" do
      before do
      end
      it "save success" do
        @eva.save.should be_true
      end
    end
    describe "Validation area-name length 100 over" do
      before do
        @eva.area = "N"*101
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation of 'area' uniqueness" do
      before do
        @eva_clone = @eva.clone
        @eva.area       = "NAME"
        @eva_clone.area = "NAME"
        @eva_clone.save!
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation name_kana length 100 over" do
      before do
        @eva.area_kana = "K"*101
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation advisory_type presence" do
      before do
        @eva.advisory_type = nil
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation advisory_type not specified value" do
      before do
        @eva.advisory_type = "A"
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation sort_criteria presence" do
      before do
        @eva.sort_criteria = nil
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation sort_criteria not specified value" do
      before do
        @eva.sort_criteria = "A"
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end

    describe "Validation issueorlift not specified value" do
      before do
        @eva.issueorlift = "A"
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation head_count not POSITIVE_INTEGER over value" do
      before do
        @eva.head_count = 2147483647 +1
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation head_count not POSITIVE_INTEGER minus value" do
      before do
        @eva.head_count = -1
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation households not POSITIVE_INTEGER over value" do
      before do
        @eva.households = 2147483647 +1
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation households not POSITIVE_INTEGER minus value" do
      before do
        @eva.households = -1
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation staff_no length 10 over" do
      before do
        @eva.staff_no = "M"*11
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation full_name length 100 over" do
      before do
        @eva.full_name = "M"*101
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation alias length 100 over" do
      before do
        @eva.alias = "A"*101
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
    describe "Validation remarks length 4000 over" do
      before do
        @eva.remarks = "N"*4001
      end
      it "save failure" do
        @eva.save.should be_false
      end
    end
  end


  describe "#human_attribute_name" do
    it "return localize field name" do
      EvacuationAdvisory.human_attribute_name(:field_disaster_code).should == "災害コード"
      EvacuationAdvisory.human_attribute_name(:field_area).should == "発令・解除地区名称"
      EvacuationAdvisory.human_attribute_name(:field_area_kana).should == "発令・解除地区名称かな"
      EvacuationAdvisory.human_attribute_name(:field_advisory_type).should == "避難勧告･指示種別"
      EvacuationAdvisory.human_attribute_name(:field_sort_criteria).should == "発令区分"
      EvacuationAdvisory.human_attribute_name(:field_issued_at).should == "発令日時"
      EvacuationAdvisory.human_attribute_name(:field_lifted_at).should == "解除日時"
      EvacuationAdvisory.human_attribute_name(:field_issueorlift).should == "発令・解除区分"
      EvacuationAdvisory.human_attribute_name(:field_head_count).should == "対象人数"
      EvacuationAdvisory.human_attribute_name(:field_households).should == "対象世帯数"
      EvacuationAdvisory.human_attribute_name(:field_identifier).should == "避難勧告_指示識別情報"
      EvacuationAdvisory.human_attribute_name(:field_staff_no).should == "発令権限者の職員番号"
      EvacuationAdvisory.human_attribute_name(:field_full_name).should == "発令権限者の氏名"
      EvacuationAdvisory.human_attribute_name(:field_alias).should == "発令権限者の別名称"
      EvacuationAdvisory.human_attribute_name(:field_remarks).should == "備考"
      EvacuationAdvisory.human_attribute_name(:field_issued_date).should == "発令日時（年月日）"
      EvacuationAdvisory.human_attribute_name(:field_issued_hm).should == "発令日時（時分）"
      EvacuationAdvisory.human_attribute_name(:field_lifted_date).should == "解除日時（年月日）"
      EvacuationAdvisory.human_attribute_name(:field_lifted_hm).should == "解除日時（時分）"
      EvacuationAdvisory.human_attribute_name(:field_changed_at).should == "移行日時"
      EvacuationAdvisory.human_attribute_name(:field_changed_date).should == "移行日時（年月日）"
      EvacuationAdvisory.human_attribute_name(:field_changed_hm).should == "移行日時（時分）"
    end
  end


  describe "#create_issues" do
    before do
      @create_commons_issue_ret = "common_issue"
#       @create_applic_issue_ret = "applic_issue"
    end
    it "return Issue array" do
      EvacuationAdvisory.should_receive(:create_commons_issue).with(@project).and_return(@create_commons_issue_ret)
#       EvacuationAdvisory.should_receive(:create_applic_issue).with(@project).and_return(@create_applic_issue_ret)
#       issues.should == [@create_commons_issue_ret, @create_applic_issue_ret]
      issues = EvacuationAdvisory.create_issues(@project)
      issues.should == [@create_commons_issue_ret]
    end
  end


#   describe "#create_applic_issue" do
#     before do
#     end
#     it "return new issue" do
#       @eva.save
#       @issue = EvacuationAdvisory.create_applic_issue(@project)
#       @issue.tracker_id.should == 30
#       @issue.project_id.should == @project.id
#       @issue.subject.should =~ /^避難勧告･指示情報 (19|20)[0-9]{2}\/(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01]) (0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])$/
#       @issue.author_id.should == User.find_by_type("AnonymousUser").id
#       
#       evacuation_advisory_key = "_避難勧告･指示 > _避難勧告･指示情報 > "
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"災害識別情報").first.text.should      ==  @project.disaster_code.to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"災害名").first.text.should            ==  @project.name.to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"都道府県").first.text.should          ==  ""
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"避難勧告･指示識別情報").first.text.should    ==  @eva.identifier.to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"避難勧告･指示名").first.text.should          ==  @eva.area.to_s
#       
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"管理者 > 職員番号").first.text.should == @eva.staff_no.to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"管理者 > 氏名 > 外字氏名").first.text.should == ""
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"管理者 > 氏名 > フリガナ").first.text.should == ""
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"管理者 > 職員別名称 > 外字氏名").first.text.should == ""
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"管理者 > 職員別名称 > フリガナ").first.text.should == ""
#       
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"報告日時 > 日付 > 年").first.text.should == @eva.changed_at.try(:year).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"報告日時 > 日付 > 月").first.text.should == @eva.changed_at.try(:month).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"報告日時 > 日付 > 日").first.text.should == @eva.changed_at.try(:day).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"報告日時 > 時").first.text.should == @eva.changed_at.try(:hour).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"報告日時 > 分").first.text.should == @eva.changed_at.try(:min).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"報告日時 > 秒").first.text.should == @eva.changed_at.try(:sec).to_s
#       
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"開設日時 > 日付 > 年").first.text.should == @eva.issued_at.try(:year).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"開設日時 > 日付 > 月").first.text.should == @eva.issued_at.try(:month).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"開設日時 > 日付 > 日").first.text.should == @eva.issued_at.try(:day).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"開設日時 > 時").first.text.should == @eva.issued_at.try(:hour).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"開設日時 > 分").first.text.should == @eva.issued_at.try(:min).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"開設日時 > 秒").first.text.should == @eva.issued_at.try(:sec).to_s
#       
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"閉鎖日時 > 日付 > 年").first.text.should == @eva.lifted_at.try(:year).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"閉鎖日時 > 日付 > 月").first.text.should == @eva.lifted_at.try(:month).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"閉鎖日時 > 日付 > 日").first.text.should == @eva.lifted_at.try(:day).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"閉鎖日時 > 時").first.text.should == @eva.lifted_at.try(:hour).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"閉鎖日時 > 分").first.text.should == @eva.lifted_at.try(:min).to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"閉鎖日時 > 秒").first.text.should == @eva.lifted_at.try(:sec).to_s
#       
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"避難者数").first.text.should   == @eva.head_count.to_s
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"避難世帯数").first.text.should == @eva.households.to_s
#       
#       Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"備考").first.text.should == @eva.remarks.to_s

#     end
#   end


  describe "#create_commons_issue" do
    describe "all value exist" do
      it "return new issue with all value" do
        @eva.save
        @issue = EvacuationAdvisory.create_commons_issue(@project)
        
        @summary = EvacuationAdvisory.select("SUM(head_count) AS head_count_sum, SUM(households) AS households_sum, COUNT(*) AS count").first
        @issue.tracker_id.should == 1
        @issue.project_id.should == @project.id
        @issue.subject.should =~ /^避難勧告･指示 / ##{@issue.published_at.xmlschema.to_s}/ 
        @issue.author_id.should == User.find_by_type("AnonymousUser").id
        
debugger
        root_key = "EvacuationAdvisory > "
#         Nokogiri::XML(@issue.xml_body).css(root_key+"Disaster > DisasterName").first.text.should == @project.name.to_s
#         Nokogiri::XML(@issue.xml_body).css(root_key+"ComplementaryInfo").first.text.should == ""
        
#         Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber > HeadCount").first.text.should           == @summary.head_count_sum.to_s
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber > Households").first.text.should          == @summary.households_sum.to_s
        
#         Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumberOfEvacuationAdvisory").first.text.should == @summary.count.to_s
        
        evacuation_advisory_key = root_key + "Informations > Information > "
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"Location > areaName").first.text.should == @eva.area.to_s
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"Location > areaNameKana").first.text.should == @eva.area_kana.to_s
        
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"Type").first.text.should == CONST["advisory_type"]["#{@eva.advisory_type}"].to_s
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"Sort").first.text.should == CONST["sort_criteria"]["#{@eva.sort_criteria}"].to_s
        
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"DateTime").first.text.should == @eva.lifted_at.xmlschema.to_s # 閉鎖の場合
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"issueorlift").first.text.should == CONST['issueorlift'][@eva.issueorlift].to_s
        
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"NumberOf > HeadCount").first.text.should           == @eva.head_count.to_s
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"NumberOf > Households").first.text.should          == @eva.households.to_s
        
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"CheckedDateTime").first.text.should == @eva.changed_at.xmlschema.to_s
        
        
      end
    end
    describe "all value not exist" do
      it "return new issue without summary, areaNameKana etc..." do
        @eva.head_count                            = nil
        @eva.households                            = nil
        
        @eva.area                                  = "NAME" # 必須項目の為、present? falseのケースは実施できず
        @eva.area_kana                             = nil
        @eva.sort_criteria                          = "5" # 常設
        
        @eva.issueorlift                                = nil
        @eva.changed_at                            = nil
        @eva.save
        
        @issue = EvacuationAdvisory.create_commons_issue(@project)
        
        @summary = EvacuationAdvisory.select("SUM(head_count) AS head_count_sum, SUM(households) AS households_sum, COUNT(*) AS count").first
        
        @issue.tracker_id.should == 1
        @issue.project_id.should == @project.id
        @issue.subject.should =~ /^避難勧告･指示 / #(19|20)[0-9]{2}\-(0[1-9]|1[0-2])\-(0[1-9]|[12][0-9]|3[01])T(0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])\+09:00$/
        @issue.author_id.should == User.find_by_type("AnonymousUser").id
        
        root_key = "EvacuationAdvisory > "
# debugger
#         Nokogiri::XML(@issue.xml_body).css(root_key+"Disaster > DisasterName").first.text.should == @project.name.to_s
#         Nokogiri::XML(@issue.xml_body).css(root_key+"ComplementaryInfo").first.text.should == ""
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber").first.should                       be_blank
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber > HeadCount").first.should           be_blank
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber > Households").first.should          be_blank
        
#         Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumberOfEvacuationAdvisory").first.text.should == @summary.count.to_s
        
        evacuation_advisory_key = root_key + "Informations > Information > "
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"Location > areaName").first.text.should == @eva.area.to_s
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"Location > areaNameKana").first.should  be_blank
        
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"Type").first.text.should == CONST["advisory_type"]["#{@eva.advisory_type}"].to_s
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"Sort").first.text.should == CONST["sort_criteria"]["#{@eva.sort_criteria}"].to_s
        
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"DateTime").first.should be_blank # 常設の場合
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"issueorlift").first.should   be_blank
        
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"NumberOf").first.should                       be_blank
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"NumberOf > HeadCount").first.should           be_blank
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"NumberOf > Households").first.should          be_blank
        
        Nokogiri::XML(@issue.xml_body).css(evacuation_advisory_key+"CheckedDateTime").first.should be_blank
      end
    end
  end

  describe "#number_evacuation_advisory_code" do
    before do
      @eva.connection.should_receive(:select_value).with("select nextval('evacuation_code_seq')").and_return("1234567890")
    end
    it "set identifier" do
      @eva.__send__(:number_evacuation_advisory_code)
      @eva.identifier.should == "04202E#{format("%014d", "1234567890")}"
    end
  end

end

# -*- coding:utf-8 -*-
require 'spec_helper'

describe Shelter do
  CONST = Constant::hash_for_table(Shelter.table_name).freeze
  I18n.locale = "ja"
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
  
  describe "Validation " do
    describe "Validation OK" do
      before do
      end
      it "save success" do
        @shelter.save.should be_true
      end
    end
    describe "Validation name presence" do
      before do
        @shelter.name = nil
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation name length 30 over" do
      before do
        @shelter.name = "N"*31
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation name uniqueness" do
      before do
        @shelter_clone = @shelter.clone
        @shelter.name       = "NAME"
        @shelter_clone.name = "NAME"
        @shelter_clone.save!
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation name_kana length 60 over" do
      before do
        @shelter.name_kana = "K"*61
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation area presence" do
      before do
        @shelter.area = nil
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation address presence" do
      before do
        @shelter.address = nil
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation address length 200 over" do
      before do
        @shelter.address = "A"*201
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation phone length 20 over" do
      before do
        @shelter.phone = "0"*21
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation phone phone_number format" do
      before do
        @shelter.phone = "A0123456789"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation fax length 20 over" do
      before do
        @shelter.fax = "0"*21
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation fax phone_number format" do
      before do
        @shelter.fax = "A0123456789"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation e_mail length 255 over" do
      before do
        @shelter.e_mail =  "aa@aa."+"a"*250
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation e_mail mail_address format" do
      before do
        @shelter.e_mail = "aa@a@aa.aa"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation person_responsible length 100 over" do
      before do
        @shelter.person_responsible = "P"*101
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation shelter_type presence" do
      before do
        @shelter.shelter_type = nil
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation shelter_type not specified value" do
      before do
        @shelter.shelter_type = "A"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation shelter_type_detail length 255 over" do
      before do
        @shelter.shelter_type_detail = "S"*256
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation shelter_sort presence" do
      before do
        @shelter.shelter_sort = nil
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation shelter_sort not specified value" do
      before do
        @shelter.shelter_sort = "A"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
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
    describe "Validation closed_date date format" do
      before do
        @shelter.closed_date = "2013-13-33"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation closed_date presence unress closed_hm.blank?" do
      before do
        @shelter.closed_date = nil
        @shelter.closed_hm = "12:12"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation closed_hm time format" do
      before do
        @shelter.closed_hm = "25:60"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation closed_hm presence unress closed_date.blank?" do
      before do
        @shelter.closed_hm = nil
        @shelter.closed_date = "2012-12-12" 
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation capacity not POSITIVE_INTEGER over value" do
      before do
        @shelter.capacity = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation capacity not POSITIVE_INTEGER minus value" do
      before do
        @shelter.capacity = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation status not specified value" do
      before do
        @shelter.status = "A"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation head_count not POSITIVE_INTEGER over value" do
      before do
        @shelter.head_count = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation head_count not POSITIVE_INTEGER minus value" do
      before do
        @shelter.head_count = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation head_count_voluntary not POSITIVE_INTEGER over value" do
      before do
        @shelter.head_count_voluntary = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation head_count_voluntary not POSITIVE_INTEGER minus value" do
      before do
        @shelter.head_count_voluntary = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation households not POSITIVE_INTEGER over value" do
      before do
        @shelter.households = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation households not POSITIVE_INTEGER minus value" do
      before do
        @shelter.households = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation households_voluntary not POSITIVE_INTEGER over value" do
      before do
        @shelter.households_voluntary = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation households_voluntary not POSITIVE_INTEGER minus value" do
      before do
        @shelter.households_voluntary = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation checked_date date format" do
      before do
        @shelter.checked_date = "2013-13-33"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation checked_date presence unress checked_hm.blank?" do
      before do
        @shelter.checked_date = nil
        @shelter.checked_hm = "12:12"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation checked_hm time format" do
      before do
        @shelter.checked_hm = "25:60"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation checked_hm presence unress checked_date.blank?" do
      before do
        @shelter.checked_hm = nil
        @shelter.checked_date = "2012-12-12" 
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation manager_code length 10 over" do
      before do
        @shelter.manager_code = "M"*11
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation manager_name length 100 over" do
      before do
        @shelter.manager_name = "M"*101
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation manager_another_name length 100 over" do
      before do
        @shelter.manager_another_name = "A"*101
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation reported_date date format" do
      before do
        @shelter.reported_date = "2013-13-33"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation reported_date presence unress reported_hm.blank?" do
      before do
        @shelter.reported_date = nil
        @shelter.reported_hm = "12:12"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation reported_hm time format" do
      before do
        @shelter.reported_hm = "25:60"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation reported_hm presence unress reported_date.blank?" do
      before do
        @shelter.reported_hm = nil
        @shelter.reported_date = "2012-12-12" 
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation building_damage_info length 4000 over" do
      before do
        @shelter.building_damage_info = "B"*4001
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation electric_infra_damage_info length 4000 over" do
      before do
        @shelter.electric_infra_damage_info = "B"*4001
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation communication_infra_damage_info length 4000 over" do
      before do
        @shelter.communication_infra_damage_info = "B"*4001
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation other_damage_info length 4000 over" do
      before do
        @shelter.other_damage_info = "B"*4001
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation usable_flag not specified value" do
      before do
        @shelter.usable_flag = "A"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation openable_flag not specified value" do
      before do
        @shelter.openable_flag = "A"
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation injury_count not POSITIVE_INTEGER over value" do
      before do
        @shelter.injury_count = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation injury_count not POSITIVE_INTEGER minus value" do
      before do
        @shelter.injury_count = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation upper_care_level_three_count not POSITIVE_INTEGER over value" do
      before do
        @shelter.upper_care_level_three_count = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation upper_care_level_three_count not POSITIVE_INTEGER minus value" do
      before do
        @shelter.upper_care_level_three_count = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation elderly_alone_count not POSITIVE_INTEGER over value" do
      before do
        @shelter.elderly_alone_count = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation elderly_alone_count not POSITIVE_INTEGER minus value" do
      before do
        @shelter.elderly_alone_count = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation elderly_couple_count not POSITIVE_INTEGER over value" do
      before do
        @shelter.elderly_couple_count = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation elderly_couple_count not POSITIVE_INTEGER minus value" do
      before do
        @shelter.elderly_couple_count = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation bedridden_elderly_count not POSITIVE_INTEGER over value" do
      before do
        @shelter.bedridden_elderly_count = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation bedridden_elderly_count not POSITIVE_INTEGER minus value" do
      before do
        @shelter.bedridden_elderly_count = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation elderly_dementia_count not POSITIVE_INTEGER over value" do
      before do
        @shelter.elderly_dementia_count = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation elderly_dementia_count not POSITIVE_INTEGER minus value" do
      before do
        @shelter.elderly_dementia_count = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation rehabilitation_certificate_count not POSITIVE_INTEGER over value" do
      before do
        @shelter.rehabilitation_certificate_count = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation rehabilitation_certificate_count not POSITIVE_INTEGER minus value" do
      before do
        @shelter.rehabilitation_certificate_count = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation physical_disability_certificate_count not POSITIVE_INTEGER over value" do
      before do
        @shelter.physical_disability_certificate_count = 2147483647 +1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation physical_disability_certificate_count not POSITIVE_INTEGER minus value" do
      before do
        @shelter.physical_disability_certificate_count = -1
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
    describe "Validation note length 4000 over" do
      before do
        @shelter.note = "N"*4001
      end
      it "save failure" do
        @shelter.save.should be_false
      end
    end
  end


  describe "#human_attribute_name" do
    it "return localize field name" do
      Shelter.human_attribute_name(:field_disaster_code).should == "災害コード"
      Shelter.human_attribute_name(:field_name).should == "避難所名"
      Shelter.human_attribute_name(:field_name_kana).should == "避難所名カナ"
      Shelter.human_attribute_name(:field_area).should == "地区名"
      Shelter.human_attribute_name(:field_address).should == "住所"
      Shelter.human_attribute_name(:field_phone).should == "電話番号"
      Shelter.human_attribute_name(:field_fax).should == "FAX番号"
      Shelter.human_attribute_name(:field_e_mail).should == "メールアドレス"
      Shelter.human_attribute_name(:field_person_responsible).should == "担当者名"
      Shelter.human_attribute_name(:field_shelter_type).should == "避難所種別"
      Shelter.human_attribute_name(:field_shelter_type_detail).should == "避難所種別の補足情報"
      Shelter.human_attribute_name(:field_shelter_sort).should == "避難所区分"
      Shelter.human_attribute_name(:field_opened_at).should == "開設日時"
      Shelter.human_attribute_name(:field_closed_at).should == "閉鎖日時"
      Shelter.human_attribute_name(:field_capacity).should == "最大の収容人数"
      Shelter.human_attribute_name(:field_status).should == "避難所状況"
      Shelter.human_attribute_name(:field_head_count).should == "人数（自主避難を含む）"
      Shelter.human_attribute_name(:field_head_count_voluntary).should == "自主避難人数"
      Shelter.human_attribute_name(:field_households).should == "世帯数（自主避難を含む）"
      Shelter.human_attribute_name(:field_households_voluntary).should == "自主避難世帯数"
      Shelter.human_attribute_name(:field_checked_at).should == "避難所状況確認日時"
      Shelter.human_attribute_name(:field_shelter_code).should == "避難所識別番号"
      Shelter.human_attribute_name(:field_manager_code).should == "管理者（職員番号）"
      Shelter.human_attribute_name(:field_manager_name).should == "管理者（名称）"
      Shelter.human_attribute_name(:field_manager_another_name).should == "管理者（別名）"
      Shelter.human_attribute_name(:field_reported_at).should == "報告日時"
      Shelter.human_attribute_name(:field_building_damage_info).should == "建物被害状況"
      Shelter.human_attribute_name(:field_electric_infra_damage_info).should == "電力被害状況"
      Shelter.human_attribute_name(:field_communication_infra_damage_info).should == "通信手段被害状況"
      Shelter.human_attribute_name(:field_other_damage_info).should == "その他の被害"
      Shelter.human_attribute_name(:field_usable_flag).should == "使用可否"
      Shelter.human_attribute_name(:field_openable_flag).should == "開設の可否"
      Shelter.human_attribute_name(:field_injury_count).should == "負傷者数"
      Shelter.human_attribute_name(:field_upper_care_level_three_count).should == "要介護度3以上"
      Shelter.human_attribute_name(:field_elderly_alone_count).should == "一人暮らし高齢者 65歳以上"
      Shelter.human_attribute_name(:field_elderly_couple_count).should == "高齢者世帯 夫婦共に65歳以上"
      Shelter.human_attribute_name(:field_bedridden_elderly_count).should == "寝たきり高齢者"
      Shelter.human_attribute_name(:field_elderly_dementia_count).should == "認知症高齢者"
      Shelter.human_attribute_name(:field_rehabilitation_certificate_count).should == "療育手帳A/A1/A2所持者"
      Shelter.human_attribute_name(:field_physical_disability_certificate_count).should == "身体障がい者手帳1/2級所持者"
      Shelter.human_attribute_name(:field_note).should == "備考"
      Shelter.human_attribute_name(:field_opened_date).should == "開設日時（年月日）"
      Shelter.human_attribute_name(:field_opened_hm).should == "開設日時（時分）"
      Shelter.human_attribute_name(:field_closed_date).should == "閉鎖日時（年月日）"
      Shelter.human_attribute_name(:field_closed_hm).should == "閉鎖日時（時分）"
      Shelter.human_attribute_name(:field_checked_date).should == "避難所状況確認日時（年月日）"
      Shelter.human_attribute_name(:field_checked_hm).should == "避難所状況確認日時（時分）"
      Shelter.human_attribute_name(:field_reported_date).should == "報告日時（年月日）"
      Shelter.human_attribute_name(:field_reported_hm).should == "報告日時（時分）"
      Shelter.human_attribute_name(:field_address_area).should == "地区名"
      Shelter.human_attribute_name(:field_address_postal_code).should == "郵便番号"
      Shelter.human_attribute_name(:field_address_state).should == "都道府県"
      Shelter.human_attribute_name(:field_address_city).should == "市区町村"
      Shelter.human_attribute_name(:field_address_street).should == "町名"
      Shelter.human_attribute_name(:field_address_number).should == "番地"
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


  describe "#create_issues" do
    before do
      @create_commons_issue_ret = "common_issue"
      @create_applic_issue_ret = "applic_issue"
    end
    it "return Issue array" do
      Shelter.should_receive(:create_commons_issue).with(@project).and_return(@create_commons_issue_ret)
      Shelter.should_receive(:create_applic_issue).with(@project).and_return(@create_applic_issue_ret)

      issues = Shelter.create_issues(@project)
      
      issues.should == [@create_commons_issue_ret, @create_applic_issue_ret]
    end
  end


  describe "#create_applic_issue" do
    before do
    end
    it "return new issue" do
      @shelter.save
      @issue = Shelter.create_applic_issue(@project)
      @issue.tracker_id.should == 31
      @issue.project_id.should == @project.id
      @issue.subject.should =~ /^避難所情報 (19|20)[0-9]{2}\/(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01]) (0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])$/
      @issue.author_id.should == User.find_by_type("AnonymousUser").id
      
      shelter_key = "_避難所 > _避難所情報 > "
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"災害識別情報").first.text.should      ==  @project.disaster_code.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"災害名").first.text.should            ==  @project.name.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"都道府県").first.text.should          ==  ""
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"市町村_消防本部名").first.text.should ==  ""
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"避難所識別情報").first.text.should    ==  @shelter.shelter_code.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"避難所名").first.text.should          ==  @shelter.name.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"電話番号").first.text.should          ==  @shelter.phone.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"FAX番号").first.text.should           ==  @shelter.fax.to_s
      
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"管理者 > 職員番号").first.text.should == @shelter.manager_code.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"管理者 > 氏名 > 外字氏名").first.text.should == ""
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"管理者 > 氏名 > 内字氏名").first.text.should == @shelter.manager_name.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"管理者 > 氏名 > フリガナ").first.text.should == ""
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"管理者 > 職員別名称 > 外字氏名").first.text.should == ""
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"管理者 > 職員別名称 > 内字氏名").first.text.should == ""
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"管理者 > 職員別名称 > フリガナ").first.text.should == ""
      
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"収容人数").first.text.should ==  @shelter.capacity.to_s
      
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"報告日時 > 日付 > 年").first.text.should == @shelter.reported_at.try(:year).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"報告日時 > 日付 > 月").first.text.should == @shelter.reported_at.try(:month).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"報告日時 > 日付 > 日").first.text.should == @shelter.reported_at.try(:day).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"報告日時 > 時").first.text.should == @shelter.reported_at.try(:hour).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"報告日時 > 分").first.text.should == @shelter.reported_at.try(:min).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"報告日時 > 秒").first.text.should == @shelter.reported_at.try(:sec).to_s
      
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"建物被害状況").first.text.should     == @shelter.building_damage_info.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"電力被害状況").first.text.should     == @shelter.electric_infra_damage_info.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"通信手段被害状況").first.text.should == @shelter.communication_infra_damage_info.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"その他の被害").first.text.should == @shelter.other_damage_info.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"使用可否").first.text.should     == CONST['usable_flag'][@shelter.usable_flag].to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"開設の可否").first.text.should   == CONST['openable_flag'][@shelter.openable_flag].to_s
      
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"開設日時 > 日付 > 年").first.text.should == @shelter.opened_at.try(:year).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"開設日時 > 日付 > 月").first.text.should == @shelter.opened_at.try(:month).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"開設日時 > 日付 > 日").first.text.should == @shelter.opened_at.try(:day).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"開設日時 > 時").first.text.should == @shelter.opened_at.try(:hour).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"開設日時 > 分").first.text.should == @shelter.opened_at.try(:min).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"開設日時 > 秒").first.text.should == @shelter.opened_at.try(:sec).to_s
      
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"閉鎖日時 > 日付 > 年").first.text.should == @shelter.closed_at.try(:year).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"閉鎖日時 > 日付 > 月").first.text.should == @shelter.closed_at.try(:month).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"閉鎖日時 > 日付 > 日").first.text.should == @shelter.closed_at.try(:day).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"閉鎖日時 > 時").first.text.should == @shelter.closed_at.try(:hour).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"閉鎖日時 > 分").first.text.should == @shelter.closed_at.try(:min).to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"閉鎖日時 > 秒").first.text.should == @shelter.closed_at.try(:sec).to_s
      
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"避難者数").first.text.should   == @shelter.head_count.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"避難世帯数").first.text.should == @shelter.households.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"負傷者数").first.text.should   == @shelter.injury_count.to_s
      
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"要援護者数 > 要介護度3以上").first.text.should == @shelter.upper_care_level_three_count.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"要援護者数 > 一人暮らし高齢者_65歳以上").first.text.should == @shelter.elderly_alone_count.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"要援護者数 > 高齢者世帯_夫婦共に65歳以上").first.text.should == @shelter.elderly_couple_count.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"要援護者数 > 寝たきり高齢者").first.text.should == @shelter.bedridden_elderly_count.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"要援護者数 > 認知症高齢者").first.text.should == @shelter.elderly_dementia_count.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"要援護者数 > 療育手帳A_A1_A2所持者").first.text.should == @shelter.rehabilitation_certificate_count.to_s
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"要援護者数 > 身体障がい者手帳1_2級所持者").first.text.should == @shelter.physical_disability_certificate_count.to_s
      
      Nokogiri::XML(@issue.xml_body).css(shelter_key+"備考").first.text.should == @shelter.note.to_s

    end
  end


  describe "#create_commons_issue" do
    describe "all value exist" do
      it "return new issue with all value" do
        @shelter.save
        @issue = Shelter.create_commons_issue(@project)
        
        @summary = Shelter.select("SUM(head_count) AS head_count_sum, SUM(head_count_voluntary) AS head_count_voluntary_sum, SUM(households) AS households_sum, SUM(households_voluntary) AS households_voluntary_sum, COUNT(*) AS count").first
        
        @issue.tracker_id.should == 2
        @issue.project_id.should == @project.id
        @issue.subject.should =~ /^避難所情報 (19|20)[0-9]{2}\-(0[1-9]|1[0-2])\-(0[1-9]|[12][0-9]|3[01])T(0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])\+09:00$/
        @issue.author_id.should == User.find_by_type("AnonymousUser").id
        
        root_key = "Shelter > "
        Nokogiri::XML(@issue.xml_body).css(root_key+"Disaster > DisasterName").first.text.should == @project.name.to_s
        Nokogiri::XML(@issue.xml_body).css(root_key+"ComplementaryInfo").first.text.should == ""
        
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber > HeadCount").first.text.should           == @summary.head_count_sum.to_s
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber > HeadCountVoluntary").first.text.should  == @summary.head_count_voluntary_sum.to_s
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber > Households").first.text.should          == @summary.households_sum.to_s
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber > HouseholdsVoluntary").first.text.should == @summary.households_voluntary_sum.to_s
        
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumberOfShelter").first.text.should == @summary.count.to_s
        
        shelter_key = root_key + "Informations > Information > "
#        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Location > edxlde:circle").first.text.should == "" # TODO: 実装コメントアウト中
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Location > areaName").first.text.should == @shelter.name.to_s
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Location > areaNameKana").first.text.should == @shelter.name_kana.to_s
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Location > ContactInfo").first.text.should == @shelter.phone.to_s
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Location > Address").first.text.should == @shelter.address.to_s
        
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Type").first.text.should == CONST["shelter_type"]["#{@shelter.shelter_type}"].to_s
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Sort").first.text.should == CONST["shelter_sort"]["#{@shelter.shelter_sort}"].to_s
        
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"DateTime").first.text.should == @shelter.closed_at.xmlschema.to_s # 閉鎖の場合
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Capacity").first.text.should == @shelter.capacity.to_s
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Status").first.text.should == CONST['status'][@shelter.status].to_s
        
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"NumberOf > HeadCount").first.text.should           == @shelter.head_count.to_s
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"NumberOf > HeadCountVoluntary").first.text.should  == @shelter.head_count_voluntary.to_s
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"NumberOf > Households").first.text.should          == @shelter.households.to_s
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"NumberOf > HouseholdsVoluntary").first.text.should == @shelter.households_voluntary.to_s
        
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"CheckedDateTime").first.text.should == @shelter.checked_at.xmlschema.to_s
        
        
      end
    end
    describe "all value not exist" do
      it "return new issue without summary, areaNameKana etc..." do
        @shelter.head_count                            = nil
        @shelter.head_count_voluntary                  = nil
        @shelter.households                            = nil
        @shelter.households_voluntary                  = nil
        
        @shelter.name                                  = "NAME" # 必須項目の為、present? falseのケースは実施できず
        @shelter.name_kana                             = nil
        @shelter.address                               = "ADDRESS" # 必須項目の為、present? falseのケースは実施できず
        @shelter.phone                                 = nil
        
        @shelter.shelter_sort                          = "5" # 常設
        
        @shelter.capacity                              = nil
        @shelter.status                                = nil
        
        @shelter.checked_at                            = nil

        @shelter.save
        
        @issue = Shelter.create_commons_issue(@project)
        
        @summary = Shelter.select("SUM(head_count) AS head_count_sum, SUM(head_count_voluntary) AS head_count_voluntary_sum, SUM(households) AS households_sum, SUM(households_voluntary) AS households_voluntary_sum, COUNT(*) AS count").first
        
        @issue.tracker_id.should == 2
        @issue.project_id.should == @project.id
        @issue.subject.should =~ /^避難所情報 (19|20)[0-9]{2}\-(0[1-9]|1[0-2])\-(0[1-9]|[12][0-9]|3[01])T(0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])\+09:00$/
        @issue.author_id.should == User.find_by_type("AnonymousUser").id
        
        root_key = "Shelter > "
        Nokogiri::XML(@issue.xml_body).css(root_key+"Disaster > DisasterName").first.text.should == @project.name.to_s
        Nokogiri::XML(@issue.xml_body).css(root_key+"ComplementaryInfo").first.text.should == ""
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber").first.should                       be_blank
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber > HeadCount").first.should           be_blank
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber > HeadCountVoluntary").first.should  be_blank
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber > Households").first.should          be_blank
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumber > HouseholdsVoluntary").first.should be_blank
        
        Nokogiri::XML(@issue.xml_body).css(root_key+"TotalNumberOfShelter").first.text.should == @summary.count.to_s
        
        shelter_key = root_key + "Informations > Information > "
#        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Location > edxlde:circle").first.text.should == "" # TODO: 実装コメントアウト中
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Location > areaName").first.text.should == @shelter.name.to_s
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Location > areaNameKana").first.should  be_blank
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Location > ContactInfo").first.should   be_blank
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Location > Address").first.text.should  == @shelter.address.to_s
        
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Type").first.text.should == CONST["shelter_type"]["#{@shelter.shelter_type}"].to_s
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Sort").first.text.should == CONST["shelter_sort"]["#{@shelter.shelter_sort}"].to_s
        
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"DateTime").first.should be_blank # 常設の場合
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Capacity").first.should be_blank
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"Status").first.should   be_blank
        
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"NumberOf").first.should                       be_blank
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"NumberOf > HeadCount").first.should           be_blank
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"NumberOf > HeadCountVoluntary").first.should  be_blank
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"NumberOf > Households").first.should          be_blank
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"NumberOf > HouseholdsVoluntary").first.should be_blank
        
        Nokogiri::XML(@issue.xml_body).css(shelter_key+"CheckedDateTime").first.should be_blank
      end
    end

  end


  describe "#release_all_data" do
    before do
      Shelter.should_receive(:write_cache)
      Shelter.should_receive(:create_json_file)
    end
    it "call write_cache, create_json_file" do
      Shelter.release_all_data
    end
  end


  describe "#write_cache" do
    before do
      @shelter.save!
      h = {}
      h[@shelter.shelter_code] = {"name" => @shelter.name, "area" => @shelter.area}
      Rails.cache.should_receive(:write).with("shelter", h)
    end
    it "call write cache" do
      Shelter.write_cache
    end
  end


  describe "#create_json_file" do
    before do
      @shelter.save!
      h = {}
      h[@shelter.shelter_code] = @shelter.name
      JSON.should_receive(:generate).with(h).and_return("json_data")
    end
    it "call create json_file" do
      Shelter.create_json_file
    end
  end


  describe "#execute_release_all_data" do
    before do
      @shelter.save!
      Shelter.should_receive(:release_all_data)
    end
    it "call release_all_data" do
      @shelter.execute_release_all_data
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


  describe "#number_shelter_code" do
    before do
      @shelter.connection.should_receive(:select_value).with("select nextval('shelter_code_seq')").and_return("1234567890")
    end
    it "set shelter_code" do
      @shelter.__send__(:number_shelter_code)
      @shelter.shelter_code.should == "04202I#{format("%014d", "1234567890")}"
    end
  end





end

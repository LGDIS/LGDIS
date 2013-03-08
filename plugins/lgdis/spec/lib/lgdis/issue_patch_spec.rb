# -*- coding:utf-8 -*-
require 'spec_helper'
describe Lgdis::IssuePatch do
  before do
    @project = FactoryGirl.build(:project1, :id => 5)
    @project.save!
    @issue = Issue.new
    @issue.id   = 1
    @issue.tracker_id   = 20 # 20: 道路通行規制に関する情報
    @issue.project_id   = @project.id
    @issue.subject      = "SUBJECT"
    @issue.description  = "DESCRIPTION"
    @issue.status_id    = 1
    @issue.priority_id  = 1
    @issue.author_id    = 1
    @issue.lock_version = 1
    @issue.done_ratio   = 1
    @issue.is_private   = true
    @issue.created_on   = Time.now
    @issue.updated_on   = Time.now+100

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
    
    @issue.mail_subject                 = "MAIL_SUBJECT"
    @issue.summary                      = "SUMMARY"
    @issue.type_update                  = "3" # 3:Cancel
    @issue.description_cancel           = "DESCRIPTION_CANCEL"
    @issue.published_date               = "2001-01-11"
    @issue.published_hm                 = "01:11"
    @issue.delivered_area               = "04102" # 04102:仙台市宮城野区
    @issue.opened_date                  = "2002-02-12"
    @issue.opened_hm                    = "02:12"
    @issue.closed_date                  = "2003-03-13"
    @issue.closed_hm                    = "03:13"
    
    
    
  end


  describe "Validation OK" do
    it "save success" do
      @issue.save.should be_true
    end
  end
  
  describe "Validation xml_control_status length 12 over" do
    before do
      @issue.xml_control_status           = 'A'*13
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_control_editorialoffice length 50 over" do
    before do
      @issue.xml_control_editorialoffice  = 'A'*51
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_control_publishingoffice length 100 over" do
    before do
      @issue.xml_control_publishingoffice = 'A'*101
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_control_cause length 1 over" do
    before do
      @issue.xml_control_cause            = 'A'*2
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_control_apply length 1 over" do
    before do
      @issue.xml_control_apply            = 'A'*2
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_head_title length 100 over" do
    before do
      @issue.xml_head_title               = 'A'*101
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_head_targetdtdubious length 8 over" do
    before do
      @issue.xml_head_targetdtdubious     = 'A'*9
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_head_targetduration length 30 over" do
    before do
      @issue.xml_head_targetduration      = 'A'*31
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_head_eventid length 64 over" do
    before do
      @issue.xml_head_eventid             = 'A'*65
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_control_editorialoffice length 50 over" do
    before do
    @issue.xml_control_editorialoffice  = 'A'*51
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_head_infotype length 8 over" do
    before do
      @issue.xml_head_infotype            = 'A'*9
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_head_serial length 8 over" do
    before do
      @issue.xml_head_serial              = 'A'*9
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_head_infokind length 100 over" do
    before do
      @issue.xml_head_infokind            = 'A'*101
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_head_infokindversion length 12 over" do
    before do
      @issue.xml_head_infokindversion     = 'A'*13
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  describe "Validation xml_head_text length 500 over" do
    before do
      @issue.xml_head_text                = 'A'*501
    end
    it "save failure" do
      @issue.save.should be_false
    end
  end
  
  
  describe "#copy_from_with_geographies " do
    before do
      @issue.save
      @issue_geography = FactoryGirl.create(:issue_geography1, :issue_id=>@issue.id)
    end
    it "copy issue_geography" do
      new_issue = Issue.new
      new_issue.copy_from_with_geographies(@issue)
      new_issue_geography = new_issue.issue_geographies[0]
      
      new_issue.tracker_id.should   == @issue.tracker_id
      new_issue.project_id.should   == @issue.project_id
      new_issue.subject.should      == @issue.subject
      new_issue.description.should  == @issue.description
      new_issue.status_id.should    == @issue.status_id
      new_issue.priority_id.should  == @issue.priority_id
      new_issue.author_id.should_not== @issue.author_id
      new_issue.lock_version.should == @issue.lock_version
      new_issue.done_ratio.should   == @issue.done_ratio
      new_issue.is_private.should   == @issue.is_private
      
      new_issue_geography.datum.should == @issue_geography.datum
      new_issue_geography.location.should == @issue_geography.location
      new_issue_geography.point.should == @issue_geography.point
      new_issue_geography.line.should == @issue_geography.line
      new_issue_geography.polygon.should == @issue_geography.polygon
      new_issue_geography.remarks.should == @issue_geography.remarks
    end
  end
  
  describe "#deliver " do
    describe "status_to == 'runtime' " do
      before do
        @issue.save
        
        @delivery_history = DeliveryHistory.new
        @delivery_history.delivery_place_id = "6"
        @status_to = "runtime"
        message_test = {"message" => "message_test"}
        
        delivery_place_id = @delivery_history.delivery_place_id
        delivery_job_class = eval(DST_LIST['delivery_place'][delivery_place_id]['delivery_job_class'])
        test_flag = DST_LIST['test_prj'][@project.id]
        
        Resque.should_receive(:enqueue).with(delivery_job_class, @delivery_history.id, message_test, test_flag)
        @issue.should_receive(:create_summary).with(delivery_place_id).and_return(message_test)
        @issue.should_receive(:init_journal).with(User.current, message_test["message"]).and_return("journal_test")
        @delivery_history.should_receive(:update_attributes)
      end
      it "return status_to" do
        @issue.deliver(@delivery_history, @status_to).should == @status_to
      end
    end
    describe "status_to == 'reject' " do
      before do
        @issue.save
        
        @delivery_history = DeliveryHistory.new
        @delivery_history.delivery_place_id = "6"
        @status_to = "reject"
        message_test = {"message" => "message_test"}
        
        delivery_place_id = @delivery_history.delivery_place_id
        delivery_job_class = eval(DST_LIST['delivery_place'][delivery_place_id]['delivery_job_class'])
        test_flag = DST_LIST['test_prj'][@project.id]
        
        Resque.should_not_receive(:enqueue)
        @issue.should_not_receive(:create_summary)
        @issue.should_not_receive(:init_journal)
        @delivery_history.should_receive(:update_attributes)
      end
      it "return status_to" do
        @issue.deliver(@delivery_history, @status_to).should == @status_to
      end
    end
    describe "status_to is not 'runtime', 'reject' " do
      before do
        @issue.save
        
        @delivery_history = DeliveryHistory.new
        @delivery_history.delivery_place_id = "6"
        @status_to = "test"
        message_test = {"message" => "message_test"}
        
        delivery_place_id = @delivery_history.delivery_place_id
        delivery_job_class = eval(DST_LIST['delivery_place'][delivery_place_id]['delivery_job_class'])
        test_flag = DST_LIST['test_prj'][@project.id]
        
        Resque.should_not_receive(:enqueue)
        @issue.should_not_receive(:create_summary)
        @issue.should_not_receive(:init_journal)
        @delivery_history.should_not_receive(:update_attributes)
      end
      it "return status_to" do
        @issue.deliver(@delivery_history, @status_to).should == @status_to
      end
    end
    describe "raise error at processing " do
      before do
        @issue.save
        
        @delivery_history = DeliveryHistory.new
        @delivery_history.delivery_place_id = "6"
        @status_to = "runtime"
        message_test = {"message" => "message_test"}
        
        delivery_place_id = @delivery_history.delivery_place_id
        delivery_job_class = eval(DST_LIST['delivery_place'][delivery_place_id]['delivery_job_class'])
        test_flag = DST_LIST['test_prj'][@project.id]
        
        @delivery_history.stub(:update_attributes) {raise "エラー"}
      end
      it "return status_to 'failed'" do
        @issue.deliver(@delivery_history, @status_to).should == 'failed'
      end
    end
  end
  
  
  describe "#create_summary " do
    before do
      @issue.save!
      @delivery_place_id = 1 # 1:公共情報コモンズ 呼び出しメソッドは create_commons_msg となる
      @ret = "return_test"
      @issue.should_receive(:create_commons_msg).with(@delivery_place_id).and_return(@ret)
    end
    it "call specified method by delivery_place_id" do
      @issue.create_summary(@delivery_place_id).should == @ret
    end
  end
  
  
  describe "#create_twitter_msg " do
    before do
      @issue.save!
      @delivery_place_id = 7 # 7:Twitter
      @return_value = "return_value"
      @issue.should_receive(:add_url_and_training).with(@issue.summary, @delivery_place_id).and_return(@return_value)
    end
    it "get summary" do
      @issue.create_twitter_msg(@delivery_place_id).should == @return_value
    end
  end
  
  
  describe "#create_facebook_msg " do
    before do
      @issue.save!
      @delivery_place_id = 8 # 8:Facebook
      @return_value = "return_value"
      @issue.should_receive(:add_url_and_training).with(@issue.summary, @delivery_place_id).and_return(@return_value)
    end
    it "get summary" do
      @issue.create_twitter_msg(@delivery_place_id).should == @return_value
    end
  end
  
  
  describe "#create_smtp_msg" do
    describe "success " do
      # TODO: mailing_list の選択基準未決(手動 & 自動)の為ロジックが未実装
      before do
        @issue.mail_subject = "MAIL_SUBJECT"
        @issue.save
        @delivery_place_id = 2 # 2:自治体職員向けメール（０号配備）
        @return_value = "return_value"
        @issue.should_receive(:add_url_and_training).with(@issue.summary, @delivery_place_id).and_return(@return_value)
      end
      it "get summary" do
        summary = @issue.create_smtp_msg(@delivery_place_id)
        # TODO: Hashのキー名が変わる可能性あり
        summary["mailing_list_name"].should == DST_LIST['delivery_place'][@delivery_place_id]['to']
        summary["title"].should == @issue.mail_subject
        summary["message"].should == @return_value
      end
    end
    describe "mail address is not found" do
      # TODO: mailing_list の選択基準未決(手動 & 自動)の為ロジックが未実装
      before do
        @issue.mail_subject = "MAIL_SUBJECT"
        @issue.save
        @delivery_place_id = 2 # 2:自治体職員向けメール（０号配備）
        @return_value = "return_value"
        @issue.should_receive(:add_url_and_training).with(@issue.summary, @delivery_place_id).and_return(@return_value)
        @tmp = DST_LIST['delivery_place'][@delivery_place_id]['to'].clone
        DST_LIST['delivery_place'][@delivery_place_id]['to'] = nil
      end
      after do
        DST_LIST['delivery_place'][@delivery_place_id]['to'] = @tmp
      end
      it "raise error" do
        lambda{summary = @issue.create_smtp_msg(@delivery_place_id)}.should raise_error("送信先アドレス設定がありません")
      end
    end
  end
  
  
  describe "#create_atom_msg " do
    before do
      @issue.save
      @issue_geography = IssueGeography.new
      @issue_geography.issue_id = @issue.id
      @issue_geography.datum    = 'DATUM'
      @issue_geography.location = 'LOCATION'
      @issue_geography.point    = '(1,2)'
      @issue_geography.line     = '((2,3),(4,5),(6,7),(8,9))'
      @issue_geography.polygon  = '((10,20),(30,40),(50,60),(70,80))'
      @issue_geography.remarks  = 'REMARKS'
      @issue_geography.save!

      @delivery_place_id = 9 # 9:災害情報ポータル"
      
    end
    it "return XML" do
       ret= @issue.create_atom_msg(@delivery_place_id)

       doc = Nokogiri::XML(ret)
       
       root_key = "feed > "
       doc.css(root_key + "title").first.text.should      ==  @project.name
       doc.css(root_key + "subtitle").first.text.should   ==  'ref: http://georss.org/simple'
       doc.css(root_key + "link[href='http://www.w3.org/2005/Atom#{CGI.new.server_name}/r/feed/']").first.text.should == ''
       doc.css(root_key + "updated").first.text.should         =~ /^(19|20)[0-9]{2}\-(0[1-9]|1[0-2])\-(0[1-9]|[12][0-9]|3[01])T(0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])\+09:00$/
       doc.css(root_key + "author > name").first.text.should   ==  @issue.author.name
       doc.css(root_key + "author > email").first.text.should  == @issue.author.mail
       doc.css(root_key + "id").first.text.should              =~ /^urn:uuid:(\w){8}\-(\w){4}\-(\w){4}\-(\w){4}\-(\w){12}$/
       doc.css(root_key + "entry > title").first.text.should   ==  "#{@issue.tracker.name} ##{@issue.id}: #{@issue.subject}"
       doc.css(root_key + "entry > id").first.text.should      =~ /^urn:uuid:(\w){8}\-(\w){4}\-(\w){4}\-(\w){4}\-(\w){12}$/
       doc.css(root_key + "entry > updated").first.text.should =~ /^(19|20)[0-9]{2}\-(0[1-9]|1[0-2])\-(0[1-9]|[12][0-9]|3[01])T(0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])\+09:00$/
       doc.css(root_key + "entry > summary").first.text.should == @issue.description.to_s[0,140]
       
# うまくXMLがパースできないので保留
#       doc.xpath("/feed/entry/georss:point").first.text.should == "2.0 1.0"
#       doc.xpath("/feed/entry/georss:relationshipTag")[0].text.should =~ /iconfile=(\d)-dot.png/
#       doc.xpath("/feed/entry/georss:line").first.text.should == "3.0 2.0 5.0 4.0 7.0 6.0 9.0 8.0"
#       doc.xpath("/feed/entry/georss:relationshipTag")[1].text.should =~ /iconfile=(\d)-dot.png/
#       doc.xpath("/feed/entry/georss:polygon").first.text.should == "20.0 10.0 40.0 30.0 60.0 50.0 80.0 70.0"
#       doc.xpath("/feed/entry/georss:relationshipTag")[2].text.should =~ /iconfile=(\d)-dot.png/
#       doc.xpath("/feed/entry/georss:featureTypeTag").first.text.should == @issue_geography.location
#       doc.xpath("/feed/entry/georss:relationshipTag")[4].text.should =~ /iconfile=(\d)-dot.png/
       
    end
  end
  
  
  describe "#create_commons_msg " do
    describe "all value exist " do
      before do
        @issue.save
        
        @issue_geography = IssueGeography.new
        @issue_geography.issue_id = @issue.id
        @issue_geography.datum    = 'DATUM'
        @issue_geography.location = 'LOCATION'
        @issue_geography.point    = '(1,2)'
        @issue_geography.line     = '((2,3),(4,5),(6,7),(8,9))'
        @issue_geography.polygon  = '((10,20),(30,40),(50,60),(70,80))'
        @issue_geography.remarks  = 'REMARKS'
        @issue_geography.save!
        
        @issue_const = Constant::hash_for_table(Issue.table_name)
        
        @delivery_place_id = 10 # 10:緊急速報メール DoCoMo
        
        @edition_management = EditionManagement.new
        @edition_management.project_id = @issue.project_id
        @edition_management.tracker_id = @issue.tracker_id
        @edition_management.issue_id = @issue.id
        @edition_management.edition_num = 1
        @edition_management.status = 3 # 3:取消
        @edition_management.uuid = "uuid-1111-2222-3333-4444"
        @edition_management.delivery_place_id = @delivery_place_id
        @edition_management.save!
        
      end
      it "return XML with all value" do
         ret= @issue.create_commons_msg(@delivery_place_id)

         doc = Nokogiri::XML(ret)

         # edxl 部
         root_key = "/edxlde:EDXLDistribution"
         doc.xpath(root_key + "/edxlde:distributionID").first.text.should          =~ /^(\w){8}\-(\w){4}\-(\w){4}\-(\w){4}\-(\w){12}$/
         doc.xpath(root_key + "/edxlde:senderID").first.text.should                == "\"editor.lgdis.city.ishinomaki\""
         doc.xpath(root_key + "/edxlde:dateTimeSent").first.text.should            =~ /^(19|20)[0-9]{2}\-(0[1-9]|1[0-2])\-(0[1-9]|[12][0-9]|3[01])T(0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])\+09:00$/
         doc.xpath(root_key + "/edxlde:distributionStatus").first.text.should      == "Actual" 
         doc.xpath(root_key + "/edxlde:distributionType").first.text.should        == "Cancel"
         doc.xpath(root_key + "/edxlde:combinedConfidentiality").first.text.should == "UNCLASSIFIED AND NOTSENSITIVE"
         
         doc.xpath(root_key + "/commons:targetArea/commons:areaName").first.text.should == "仙台市宮城野区"
         doc.xpath(root_key + "/commons:targetArea/commons:jisX0402").first.text.should == "04102"
         doc.xpath(root_key + "/commons:contentObject/edxlde:contentDescription").first.text.should == @issue.summary
         doc.xpath(root_key + "/commons:contentObject/edxlde:consumerRole/edxlde:valueListUrn").first.text.should == "publicCommons:media:urgentmail:carrier"
         doc.xpath(root_key + "/commons:contentObject/edxlde:consumerRole/edxlde:value").first.text.should == DST_LIST['commons_xml_field']['carrier'][@delivery_place_id]
         
         # Control 部
         controll_key = root_key + "/commons:contentObject/edxlde:xmlContent/edxlde:embeddedXMLContent/Report/Control"
         doc.xpath(controll_key + "/Title").first.text.should == "UrgentMail" # テンプレートxmlにハードコーディング
         doc.xpath(controll_key + "/edxlde:distributionStatus").first.text.should == "Actual"
         doc.xpath(controll_key + "/EditorialOffice/pcx_eb:OrganizationCode").first.text.should  == DST_LIST['commons_xml_field']['organization_code']
         doc.xpath(controll_key + "/EditorialOffice/pcx_eb:OfficeName").first.text.should        == DST_LIST['commons_xml_field']['editorial_office']
         doc.xpath(controll_key + "/EditorialOffice/pcx_eb:OrganizationName").first.text.should  == DST_LIST['commons_xml_field']['organization_name']
         doc.xpath(controll_key + "/PublishingOffice/pcx_eb:OrganizationCode").first.text.should == DST_LIST['commons_xml_field']['organization_code']
         doc.xpath(controll_key + "/PublishingOffice/pcx_eb:OfficeName").first.text.should       == DST_LIST['commons_xml_field']['publishing_office']
         doc.xpath(controll_key + "/PublishingOffice/pcx_eb:ContactInfo[@pcx_eb:contactType='phone']").first.text.should == DST_LIST['commons_xml_field']['contact_type']
         doc.xpath(controll_key + "/PublishingOffice/pcx_eb:OrganizationName").first.text.should == DST_LIST['commons_xml_field']['organization_name']
         doc.xpath(controll_key + "/Errata/pcx_eb:Description").first.text.should == @issue.description_cancel
         doc.xpath(controll_key + "/Errata/pcx_eb:Datetime").first.text.should == @issue.updated_on.xmlschema
         
         # Head 部
         head_key = root_key + "/commons:contentObject/edxlde:xmlContent/edxlde:embeddedXMLContent/Report/pcx_ib:Head"
         doc.xpath(head_key + "/pcx_ib:Title").first.text.should == I18n.t('target_municipality') + ' ' + @issue.project.name + ' ' + DST_LIST['tracker_title'][@issue.tracker_id]
         doc.xpath(head_key + "/pcx_ib:CreateDateTime").first.text.should == @issue.created_on.xmlschema
         doc.xpath(head_key + "/pcx_ib:FirstCreateDateTime").first.text.should == @issue.created_on.xmlschema
         doc.xpath(head_key + "/pcx_ib:FirstCreateDateTime").first.text.should == @issue.created_on.xmlschema
         doc.xpath(head_key + "/pcx_ib:TargetDateTime").first.text.should == @issue.opened_at.xmlschema
         doc.xpath(head_key + "/pcx_ib:ValidDateTime").first.text.should == @issue.closed_at.xmlschema
         doc.xpath(head_key + "/edxlde:distributionID").first.text.should =~ /^(\w){8}\-(\w){4}\-(\w){4}\-(\w){4}\-(\w){12}$/
         doc.xpath(head_key + "/edxlde:distributionType").first.text.should == "Cancel" # @issue.type_update = 3
         doc.xpath(head_key + "/commons:documentRevision").first.text.should == (@edition_management.edition_num+1).to_s
         doc.xpath(head_key + "/commons:documentID").first.text.should == @edition_management.uuid
         doc.xpath(head_key + "/pcx_ib:Headline/pcx_ib:Text").first.text.should == @issue.summary
         doc.xpath(head_key + "/pcx_ib:Headline/pcx_ib:Areas/pcx_ib:Area/commons:areaName").first.text.should == DST_LIST['commons_xml_field']['area_name']
         
         # Body 部 緊急速報メールのパターンでの検証
         body_key = root_key + "/commons:contentObject/edxlde:xmlContent/edxlde:embeddedXMLContent/Report/pcx_um:UrgentMail"
         doc.xpath(body_key + "/pcx_um:Information/pcx_um:Title").first.text.should   == @issue.mail_subject
         doc.xpath(body_key + "/pcx_um:Information/pcx_um:Message").first.text.should == @issue.summary
         
         # edxl 部
         doc.xpath(root_key + "/commons:contentObject/commons:publishingOfficeName").first.text.should     == DST_LIST['commons_xml_field']['publishing_office']
         doc.xpath(root_key + "/commons:contentObject/commons:publishingOfficeID").first.text.should       == DST_LIST['commons_xml_field']['organization_code']
         doc.xpath(root_key + "/commons:contentObject/commons:previousDocumentRevision").first.text.should == (@edition_management.edition_num+1-1).to_s # 処理中に1増やしている
         doc.xpath(root_key + "/commons:contentObject/commons:documentRevision").first.text.should         == (@edition_management.edition_num+1).to_s   # 処理中に1増やしている
         doc.xpath(root_key + "/commons:contentObject/commons:documentID").first.text.should               == @edition_management.uuid
         doc.xpath(root_key + "/commons:contentObject/commons:category").first.text.should                 == "UrgentMail" # テンプレートxmlにハードコーディング
      end
    end
    describe "any elements not output " do
      before do
        @issue.opened_at =nil
        @issue.closed_at =nil
        @issue.type_update = 2 # 2:Update Errataの要素が出力されない
        @issue.save
        
        @issue_geography = IssueGeography.new
        @issue_geography.issue_id = @issue.id
        @issue_geography.datum    = 'DATUM'
        @issue_geography.location = 'LOCATION'
        @issue_geography.point    = '(1,2)'
        @issue_geography.line     = '((2,3),(4,5),(6,7),(8,9))'
        @issue_geography.polygon  = '((10,20),(30,40),(50,60),(70,80))'
        @issue_geography.remarks  = 'REMARKS'
        @issue_geography.save!
        
        @issue_const = Constant::hash_for_table(Issue.table_name)
        
        @delivery_place_id = 9 # 9 災害情報ポータル 緊急速報メールでしか出力されない要素がある
        
        @edition_management = EditionManagement.new
        @edition_management.project_id = @issue.project_id
        @edition_management.tracker_id = @issue.tracker_id
        @edition_management.issue_id = @issue.id
        @edition_management.edition_num = 1
        @edition_management.status = 2 # 2:更新 (旧ロジックでErrataの要素が出力されない)
        @edition_management.uuid = "uuid-1111-2222-3333-4444"
        @edition_management.delivery_place_id = @delivery_place_id
        @edition_management.save!
        
        @tmp = DST_LIST['commons_xml_field']['contact_type'].clone
        DST_LIST['commons_xml_field']['contact_type'] = nil
        
      end
      after do
        DST_LIST['commons_xml_field']['contact_type'] = @tmp
      end
      it "return XML without any values" do
         ret= @issue.create_commons_msg(@delivery_place_id)

         doc = Nokogiri::XML(ret)

         # edxl 部
         root_key = "/edxlde:EDXLDistribution"
         doc.xpath(root_key + "/edxlde:distributionID").first.text.should          =~ /^(\w){8}\-(\w){4}\-(\w){4}\-(\w){4}\-(\w){12}$/
         doc.xpath(root_key + "/edxlde:senderID").first.text.should                == "\"editor.lgdis.city.ishinomaki\""
         doc.xpath(root_key + "/edxlde:dateTimeSent").first.text.should            =~ /^(19|20)[0-9]{2}\-(0[1-9]|1[0-2])\-(0[1-9]|[12][0-9]|3[01])T(0?[0-9]|1[0-9]|2[0-3]):([0-5]?[0-9]):([0-5]?[0-9])\+09:00$/
         doc.xpath(root_key + "/edxlde:distributionStatus").first.text.should      == "Actual" 
         doc.xpath(root_key + "/edxlde:distributionType").first.text.should        == "Update"
         doc.xpath(root_key + "/edxlde:combinedConfidentiality").first.text.should == "UNCLASSIFIED AND NOTSENSITIVE"
         
         doc.xpath(root_key + "/commons:targetArea/commons:areaName").first.text.should == "仙台市宮城野区"
         doc.xpath(root_key + "/commons:targetArea/commons:jisX0402").first.text.should == "04102"
         doc.xpath(root_key + "/commons:contentObject/edxlde:contentDescription").first.text.should == @issue.summary
         doc.xpath(root_key + "/commons:contentObject/edxlde:consumerRole/edxlde:valueListUrn").first.should be_nil
         doc.xpath(root_key + "/commons:contentObject/edxlde:consumerRole/edxlde:value").first.should be_nil
         
         # Control 部
         controll_key = root_key + "/commons:contentObject/edxlde:xmlContent/edxlde:embeddedXMLContent/Report/Control"
         doc.xpath(controll_key + "/Title").first.text.should == "GeneralInformation" # テンプレートxmlにハードコーディング
         doc.xpath(controll_key + "/edxlde:distributionStatus").first.text.should == "Actual"
         doc.xpath(controll_key + "/EditorialOffice/pcx_eb:OrganizationCode").first.text.should  == DST_LIST['commons_xml_field']['organization_code']
         doc.xpath(controll_key + "/EditorialOffice/pcx_eb:OfficeName").first.text.should        == DST_LIST['commons_xml_field']['editorial_office']
         doc.xpath(controll_key + "/EditorialOffice/pcx_eb:OrganizationName").first.text.should  == DST_LIST['commons_xml_field']['organization_name']
         doc.xpath(controll_key + "/PublishingOffice/pcx_eb:OrganizationCode").first.text.should == DST_LIST['commons_xml_field']['organization_code']
         doc.xpath(controll_key + "/PublishingOffice/pcx_eb:OfficeName").first.text.should       == DST_LIST['commons_xml_field']['publishing_office']
         doc.xpath(controll_key + "/PublishingOffice/pcx_eb:ContactInfo[@pcx_eb:contactType='phone']").first.should be_nil
         doc.xpath(controll_key + "/PublishingOffice/pcx_eb:OrganizationName").first.text.should == DST_LIST['commons_xml_field']['organization_name']
         doc.xpath(controll_key + "/Errata/pcx_eb:Description").first.should be_nil
         doc.xpath(controll_key + "/Errata/pcx_eb:Datetime").first.should be_nil
         
         # Head 部
         head_key = root_key + "/commons:contentObject/edxlde:xmlContent/edxlde:embeddedXMLContent/Report/pcx_ib:Head"
         doc.xpath(head_key + "/pcx_ib:Title").first.text.should == I18n.t('target_municipality') + ' ' + @issue.project.name + ' ' + DST_LIST['tracker_title'][@issue.tracker_id]
         doc.xpath(head_key + "/pcx_ib:CreateDateTime").first.text.should == @issue.created_on.xmlschema
         doc.xpath(head_key + "/pcx_ib:FirstCreateDateTime").first.text.should == @issue.created_on.xmlschema
         doc.xpath(head_key + "/pcx_ib:FirstCreateDateTime").first.text.should == @issue.created_on.xmlschema
         doc.xpath(head_key + "/pcx_ib:TargetDateTime").first.should be_nil
         doc.xpath(head_key + "/pcx_ib:ValidDateTime").first.should be_nil
         doc.xpath(head_key + "/edxlde:distributionID").first.text.should =~ /^(\w){8}\-(\w){4}\-(\w){4}\-(\w){4}\-(\w){12}$/
         doc.xpath(head_key + "/edxlde:distributionType").first.text.should == "Update" # @issue.type_update = 2
         doc.xpath(head_key + "/commons:documentRevision").first.text.should == (@edition_management.edition_num+1).to_s
         doc.xpath(head_key + "/commons:documentID").first.text.should == @edition_management.uuid
         doc.xpath(head_key + "/pcx_ib:Headline/pcx_ib:Text").first.text.should == @issue.summary
         doc.xpath(head_key + "/pcx_ib:Headline/pcx_ib:Areas/pcx_ib:Area/commons:areaName").first.text.should == DST_LIST['commons_xml_field']['area_name']
         
         # Body 部 災害情報ポータルのパターンでの検証なので出力なし
         
         # edxl 部
         doc.xpath(root_key + "/commons:contentObject/commons:publishingOfficeName").first.text.should     == DST_LIST['commons_xml_field']['publishing_office']
         doc.xpath(root_key + "/commons:contentObject/commons:publishingOfficeID").first.text.should       == DST_LIST['commons_xml_field']['organization_code']
         doc.xpath(root_key + "/commons:contentObject/commons:previousDocumentRevision").first.text.should == (@edition_management.edition_num+1-1).to_s # 処理中に1増やしている
         doc.xpath(root_key + "/commons:contentObject/commons:documentRevision").first.text.should         == (@edition_management.edition_num+1).to_s   # 処理中に1増やしている
         doc.xpath(root_key + "/commons:contentObject/commons:documentID").first.text.should               == @edition_management.uuid
         doc.xpath(root_key + "/commons:contentObject/commons:category").first.text.should                 == "GeneralInformation" # テンプレートxmlにハードコーディング
      end
    end
  end
  
  
  describe "#add_url_and_training " do
    before do
      @issue.save
    end
    describe "DST_LIST['smtp']['target_num'] specified " do
      it "return DST_LIST['lgdsf_url']" do
        summary = @issue.add_url_and_training(@issue.description, 2) # DST_LIST['delivery_place'][delivery_place_id]に2(自治体職員向けメール（０号配備）でadd_url_typeはlgdsf_url
        url = DST_LIST['lgdsf_url'] + '?' + Time.now.strftime("%Y%m%d%H%M%S")
        summary.should == DST_LIST['disaster_portal_url'] + "\n" + url.to_s + "\n" + @issue.description
      end
    end
    describe "DST_LIST['smtp']['target_num'] not specified " do
      it "return DST_LIST['disaster_portal_url']" do
        summary = @issue.add_url_and_training(@issue.description, 1) # DST_LIST['delivery_place'][delivery_place_id]に1(公共情報コモンズ)でadd_url_typeはdisaster_portal_url
        url = ''
        summary.should == DST_LIST['disaster_portal_url'] + "\n" + url.to_s + "\n" + @issue.description
      end
    end
    describe "training_mode specified " do
      before do
        @project2 = FactoryGirl.build(:project1, :id => 2) # 2:災害訓練モードプロジェクトID
        @project2.save!
        @issue.project_id = @project2.id
      end
      it "return add training mode prefix" do
        summary = @issue.add_url_and_training(@issue.description, 2) 
        url = DST_LIST['lgdsf_url'] + '?' + Time.now.strftime("%Y%m%d%H%M%S")
        summary.should == "【災害訓練】" + "\n" + DST_LIST['disaster_portal_url'] + "\n" + url.to_s + "\n" + @issue.description
      end
    end
  end
  
  
  describe "#locations_for_map " do
    before do
      @issue.save
      @issue_geography = IssueGeography.new
      @issue_geography.issue_id = @issue.id
      @issue_geography.datum    = 'DATUM'
      @issue_geography.location = 'LOCATION'
      @issue_geography.point    = '(1,2)'
      @issue_geography.line     = '((2,3),(4,5),(6,7),(8,9))'
      @issue_geography.polygon  = '((10,20),(30,40),(50,60),(70,80))'
      @issue_geography.remarks  = 'REMARKS'
      @issue_geography.save!
    end
    it "return locations hash array" do
      @issue.locations_for_map.should == [@issue_geography.location_for_map]
    end
  end
  
  
  describe "#points_for_map " do
    before do
      @issue.save
      @issue_geography = IssueGeography.new
      @issue_geography.issue_id = @issue.id
      @issue_geography.datum    = 'DATUM'
      @issue_geography.location = 'LOCATION'
      @issue_geography.point    = '(1,2)'
      @issue_geography.line     = '((2,3),(4,5),(6,7),(8,9))'
      @issue_geography.polygon  = '((10,20),(30,40),(50,60),(70,80))'
      @issue_geography.remarks  = 'REMARKS'
      @issue_geography.save!
    end
    it "return points hash array" do
      @issue.points_for_map(IssueGeography::DATUM_JGD).should == [@issue_geography.point_for_map(IssueGeography::DATUM_JGD)]
    end
  end
  
  
  describe "#lines_for_map " do
    before do
      @issue.save
      @issue_geography = IssueGeography.new
      @issue_geography.issue_id = @issue.id
      @issue_geography.datum    = 'DATUM'
      @issue_geography.location = 'LOCATION'
      @issue_geography.point    = '(1,2)'
      @issue_geography.line     = '((2,3),(4,5),(6,7),(8,9))'
      @issue_geography.polygon  = '((10,20),(30,40),(50,60),(70,80))'
      @issue_geography.remarks  = 'REMARKS'
      @issue_geography.save!
    end
    it "return lines hash array" do
      @issue.lines_for_map(IssueGeography::DATUM_JGD).should == [@issue_geography.line_for_map(IssueGeography::DATUM_JGD)]
    end
  end
  
  
  describe "#polygons_for_map " do
    before do
      @issue.save
      @issue_geography = IssueGeography.new
      @issue_geography.issue_id = @issue.id
      @issue_geography.datum    = 'DATUM'
      @issue_geography.location = 'LOCATION'
      @issue_geography.point    = '(1,2)'
      @issue_geography.line     = '((2,3),(4,5),(6,7),(8,9))'
      @issue_geography.polygon  = '((10,20),(30,40),(50,60),(70,80))'
      @issue_geography.remarks  = 'REMARKS'
      @issue_geography.save!
    end
    it "return polygons hash array" do
      @issue.polygons_for_map(IssueGeography::DATUM_JGD).should == [@issue_geography.polygon_for_map(IssueGeography::DATUM_JGD)]
    end
  end
  
  
  describe "#create_commons_event_body " do
    before do
      @issue.save
    end
    it "return common event body part XML" do
      @issue_const = Constant::hash_for_table(Issue.table_name)
      ret = @issue.create_commons_event_body
      # 解析用にprefix定義の記述があるBODY部の開始・終了の部分を付加する
      he = '<body_namespace xmlns:pcx_gi="http_gi" xmlns:pcx_eb="http_eb"> '
      fo = '</body_namespace>'
      
      ret = he + ret + fo
      doc = Nokogiri::XML(ret)
      
      root_key = "/body_namespace/pcx_gi:GeneralInformation"
      doc.xpath(root_key + "/pcx_gi:DisasterInformationType").first.text.should      == @issue.code_in_custom_field_value(DST_LIST['custom_field_delivery']['info_classification'])
      doc.xpath(root_key + "/pcx_eb:Disaster/pcx_eb:DisasterName").first.text.should == @project.name
      doc.xpath(root_key + "/pcx_gi:Category").first.text.should    == "#{DST_LIST['tracker_grouping'][@issue.tracker_id][0]}"
      doc.xpath(root_key + "/pcx_gi:subCategory").first.text.should == "#{DST_LIST['tracker_grouping'][@issue.tracker_id][1]}"
      doc.xpath(root_key + "/pcx_gi:Title").first.text.should == I18n.t('target_municipality') + ' ' + @issue.project.name + ' ' + DST_LIST['tracker_title'][@issue.tracker_id]
      doc.xpath(root_key + "/pcx_gi:Description").first.text.should == @issue.description.to_s
      doc.xpath(root_key + "/pcx_gi:URL").first.text.should == @issue.__send__(:name_in_custom_field_value, 37).to_s # 関連するホームページ
      
    end
  end
  
  
  describe "#create_commons_area_mail_body " do
    before do
      @issue.save
    end
    it "return area mail body part XML" do
      ret = @issue.__send__(:create_commons_area_mail_body)
      # 解析用にprefix定義の記述があるBODY部の開始・終了の部分を付加する
      he = '<body_namespace xmlns:pcx_um="http_um"> '
      fo = '</body_namespace>'
      
      ret = he + ret + fo
      doc = Nokogiri::XML(ret)
      
      root_key = "/body_namespace/pcx_um:UrgentMail/pcx_um:Information"
      doc.xpath(root_key + "/pcx_um:Title").first.text.should   == @issue.mail_subject
      doc.xpath(root_key + "/pcx_um:Message").first.text.should == @issue.summary
      
    end
  end
  
  
  describe "#set_edition_mng_field " do
    describe "edition_management present, type_update not 1 " do
      before do
        @issue.type_update = 2
        @issue.save
        @delivery_place_id = 9 # 9 災害情報ポータル 緊急速報メールでしか出力されない要素がある
        
        @edition_management = EditionManagement.new
        @edition_management.project_id = @issue.project_id
        @edition_management.tracker_id = @issue.tracker_id
        @edition_management.issue_id = @issue.id
        @edition_management.edition_num = 2
        @edition_management.status = 2
        @edition_management.uuid = "uuid-1111-2222-3333-4444"
        @edition_management.delivery_place_id = @delivery_place_id
        @edition_management.save!
        
      end
      it "return area mail body part XML" do
        ret = @issue.__send__(:set_edition_mng_field, @edition_management)
        ret["uuid"].should == @edition_management.uuid
        ret["status"].should == @issue.type_update.to_i
        ret["edition_num"].should == @edition_management.edition_num+1
      end
    end
    describe "edition_management present, type_update 1 " do
      before do
        @issue.type_update = 1
        @issue.save
        @delivery_place_id = 9 # 9 災害情報ポータル 緊急速報メールでしか出力されない要素がある
        
        @edition_management = EditionManagement.new
        @edition_management.project_id = @issue.project_id
        @edition_management.tracker_id = @issue.tracker_id
        @edition_management.issue_id = @issue.id
        @edition_management.edition_num = 2
        @edition_management.status = 1
        @edition_management.uuid = "uuid-1111-2222-3333-4444"
        @edition_management.delivery_place_id = @delivery_place_id
        @edition_management.save!
        
      end
      it "return area mail body part XML" do
        ret = @issue.__send__(:set_edition_mng_field, @edition_management)
        ret["uuid"].should =~ /^(\w){8}\-(\w){4}\-(\w){4}\-(\w){4}\-(\w){12}$/
        ret["status"].should == @issue.type_update.to_i
        ret["edition_num"].should == 1
      end
    end
    describe "edition_management nil " do
      before do
        @issue.save
        @delivery_place_id = 9 # 9 災害情報ポータル 緊急速報メールでしか出力されない要素がある
        
        @edition_management = nil
      end
      it "return area mail body part XML" do
        ret = @issue.__send__(:set_edition_mng_field, @edition_management)
        ret["uuid"].should =~ /^(\w){8}\-(\w){4}\-(\w){4}\-(\w){4}\-(\w){12}$/
        ret["status"].should == @issue.type_update.to_i
        ret["edition_num"].should == 1
      end
    end
  end
  
  
  describe "#find_edition_mng " do
    before do
      @issue.save
      
      @edition_management1 = EditionManagement.new
      @edition_management1.project_id = 50
      @edition_management1.tracker_id = 50
      @edition_management1.issue_id = @issue.id
      @edition_management1.edition_num = 2
      @edition_management1.status = 2 # 2:更新 Errataの要素が出力されない
      @edition_management1.uuid = "uuid-1111-1111-1111-1111"
      @edition_management1.delivery_place_id = 10
      @edition_management1.save!
      
      @edition_management2 = EditionManagement.new
      @edition_management2.project_id = 50
      @edition_management2.tracker_id = 50
      @edition_management2.issue_id = @issue.id
      @edition_management2.edition_num = 2
      @edition_management2.status = 2 # 2:更新 Errataの要素が出力されない
      @edition_management2.uuid = "uuid-2222-2222-2222-2222"
      @edition_management2.delivery_place_id = 20
      @edition_management2.save!
      
      @edition_management3 = EditionManagement.new
      @edition_management3.project_id = @issue.project_id
      @edition_management3.tracker_id = 10
      @edition_management3.issue_id = 50
      @edition_management3.edition_num = 2
      @edition_management3.status = 2 # 2:更新 Errataの要素が出力されない
      @edition_management3.uuid = "uuid-3333-3333-3333-3333"
      @edition_management3.delivery_place_id = 10
      @edition_management3.save!
      
      @edition_management4 = EditionManagement.new
      @edition_management4.project_id = @issue.project_id
      @edition_management4.tracker_id = 10
      @edition_management4.issue_id = 50
      @edition_management4.edition_num = 2
      @edition_management4.status = 2 # 2:更新 Errataの要素が出力されない
      @edition_management4.uuid = "uuid-4444-4444-4444-4444"
      @edition_management4.delivery_place_id = 20
      @edition_management4.save!
      
      @edition_management5 = EditionManagement.new
      @edition_management5.project_id = 50
      @edition_management5.tracker_id = 50
      @edition_management5.issue_id = 50
      @edition_management5.edition_num = 2
      @edition_management5.status = 2 # 2:更新 Errataの要素が出力されない
      @edition_management5.uuid = "uuid-5555-5555-5555-5555"
      @edition_management5.delivery_place_id = 50
      @edition_management5.save!
      
    end
    describe "generalinfo,  ugent mail " do
      it "issue_id,  delivery_place_id in ugent_mail_ids matching" do
        @issue.tracker_id  = 20 # イベント・お知らせのトラッカー
        @delivery_place_id = 10 # 緊急速報メール
        @issue.save!
        ret = @issue.__send__(:find_edition_mng, @delivery_place_id)
        ret.should == @edition_management1
      end
    end
    describe "generalinfo, not ugent mail " do
      it "issue_id,  delivery_place_id not in ugent_mail_ids matching" do
        @issue.tracker_id  = 20 # イベント・お知らせのトラッカー
        @delivery_place_id = 5  # 緊急速報メール以外
        @issue.save!
        ret = @issue.__send__(:find_edition_mng, @delivery_place_id)
        ret.should == @edition_management2
      end
    end
    describe "not generalinfo, ugent mail " do
      it "project_id, tracker_id,  delivery_place_id in ugent_mail_ids matching" do
        @issue.tracker_id  = 10 # イベント・お知らせのトラッカー以外
        @delivery_place_id = 10 # 緊急速報メール
        @issue.save!
        ret = @issue.__send__(:find_edition_mng, @delivery_place_id)
        ret.should == @edition_management3
      end
    end
    describe "not generalinfo, not ugent mail " do
      it "project_id, tracker_id,  delivery_place_id not in ugent_mail_ids matching" do
        @issue.tracker_id  = 10 # イベント・お知らせのトラッカー以外
        @delivery_place_id = 5  # 緊急速報メール以外
        @issue.save!
        ret = @issue.__send__(:find_edition_mng, @delivery_place_id)
        ret.should == @edition_management4
      end
    end
    describe "not found condition " do
      it "edition_management not found " do
        @issue.tracker_id  = 11
        @delivery_place_id = 90
        @issue.save!
        ret = @issue.__send__(:find_edition_mng, @delivery_place_id)
        ret.should be_nil
      end
    end
  end
  
  
  describe "#get_area_name " do
    before do
      @issue.save
    end
    it "return code:area_name string" do
      
      areas = IssueCustomField.find_by_id(DST_LIST["custom_field_list"]["area"]["id"]).possible_values
      areas.each do |area|
        key, value = area.split(":")
        @issue.__send__(:get_area_name, key).should == key + ":" + value
      end
      
      
    end
  end
  
  
end

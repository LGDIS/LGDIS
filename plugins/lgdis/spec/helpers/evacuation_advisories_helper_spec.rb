# -*- coding:utf-8 -*-
require 'spec_helper'
include EvacuationAdvisoriesHelper
include ActionView::Helpers::TagHelper # content_tag メソッドを実行する為に必要
include ActionView::Context # content_tag メソッドを実行する為に必要
include ERB::Util # h メソッドを実行する為に必要

describe EvacuationAdvisoriesHelper do
  
  describe "#localize_scoped" do
    describe "right scope" do
      before do
        @key = "name"
        params = {:controller => "evacuation_advisories"}
        EvacuationAdvisoriesHelper.stub(:params) {params}
        EvacuationAdvisoriesHelper.should_receive(:l).with(("field_"+@key.to_s).to_sym, :scope => params[:controller], :raise => true).and_return("OK")
      end
      it "return localized value in specified scope" do
        EvacuationAdvisoriesHelper.localize_scoped(@key).should == "OK"
      end
    end
    describe "invalid scope" do
      before do
        @key = "name"
        params = {:controller => "evacuation_advisories_invalid"}
        EvacuationAdvisoriesHelper.stub(:params) {params}
        EvacuationAdvisoriesHelper.should_receive(:l).with(("field_"+@key.to_s).to_sym, :scope => params[:controller], :raise => true).and_raise
        EvacuationAdvisoriesHelper.should_receive(:l).with(("field_"+@key.to_s).to_sym).and_return("OK")
      end
      it "return localized value in all scope" do
        EvacuationAdvisoriesHelper.localize_scoped(@key).should == "OK"
      end
    end
  end
  
  
  describe "#field_for" do
    describe "specify label" do
      before do
        @key = "test_key"
        @options = {:label => "test_label"} 
      end
      it "specified label value" do
        ret = EvacuationAdvisoriesHelper.field_for(@key, @options) do|key,label|
          label
        end
        ret.should == "<p>"+ @options[:label].html_safe + "</p>"
        
      end
    end
    describe "not specify label" do
      before do
        @key = :name # :name は日本語化すると 名称 となる。
        @options = {:label => nil} 
      end
      it "key parameter localized value" do
        ret = EvacuationAdvisoriesHelper.field_for(@key, @options) do|key,label|
          label
        end
        ret.should == "<p>名称</p>"
        
      end
    end
    describe "option required true" do
      before do
        @key = :name # :name は日本語化すると 名称 となる。
        @options = {:label => nil, :required => true} 
      end
      it "add class attribute" do
        ret = EvacuationAdvisoriesHelper.field_for(@key, @options) do|key,label|
          label
        end
        ret.should == "<p>名称<span class=\"required\"> *</span></p>"
        
      end
    end
  end
  
  
  describe "#error_messages_for_evacuation_advisories" do
    before do
      @evacuation_advisory1 = FactoryGirl.create(:evacuation_advisory1, :area =>"地区１", :issued_at=>"2001-12-15 10:11", :identifier=>"04202E00000000000006", :households=>20, :head_count=>5)
      @evacuation_advisory2 = FactoryGirl.create(:evacuation_advisory1, :area =>"地区２", :issued_at=>"2001-12-15 10:11", :identifier=>"04202E00000000000007", :households=>21, :head_count=>6)
      @evacuation_advisory1.lifted_hm = "12:13"
      @evacuation_advisory2.changed_hm = "10:11"
      @evacuation_advisory1.save # saveしてエラーを発生させる
      @evacuation_advisory2.save # saveしてエラーを発生させる
    end
    it "return error specified label value" do
      ret = EvacuationAdvisoriesHelper.error_messages_for_evacuation_advisories([@evacuation_advisory1, @evacuation_advisory2])
      ret.should == "<div id='errorExplanation'><ul>\n<li>避難勧告_指示識別情報&quot;04202E00000000000006&quot;の解除日時（年月日） を入力してください。</li>\n<li>避難勧告_指示識別情報&quot;04202E00000000000007&quot;の移行日時（年月日） を入力してください。</li>\n</ul></div>\n"
      
    end
  end
  
  
end

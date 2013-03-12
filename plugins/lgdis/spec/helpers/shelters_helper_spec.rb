# -*- coding:utf-8 -*-
require 'spec_helper'
include SheltersHelper
include ActionView::Helpers::TagHelper
include ActionView::Context
include ERB::Util

describe SheltersHelper do
  
  describe "#localize_scoped" do
    describe "right scope" do
      before do
        @key = "name"
        params = {:controller => "shelters"}
        SheltersHelper.stub(:params) {params}
        SheltersHelper.should_receive(:l).with(("field_"+@key.to_s).to_sym, :scope => params[:controller], :raise => true).and_return("OK")
      end
      it "return localized value in specified scope" do
        SheltersHelper.localize_scoped(@key).should == "OK"
      end
    end
    describe "invalid scope" do
      before do
        @key = "name"
        params = {:controller => "shelters_invalid"}
        SheltersHelper.stub(:params) {params}
        SheltersHelper.should_receive(:l).with(("field_"+@key.to_s).to_sym, :scope => params[:controller], :raise => true).and_raise
        SheltersHelper.should_receive(:l).with(("field_"+@key.to_s).to_sym).and_return("OK")
      end
      it "return localized value in all scope" do
        SheltersHelper.localize_scoped(@key).should == "OK"
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
        ret = SheltersHelper.field_for(@key, @options) do|key,label|
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
        ret = SheltersHelper.field_for(@key, @options) do|key,label|
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
        ret = SheltersHelper.field_for(@key, @options) do|key,label|
          label
        end
        ret.should == "<p>名称<span class=\"required\"> *</span></p>"
        
      end
    end
  end
  
  
  describe "#error_messages_for_shelters" do
    before do
      @shelter1 = FactoryGirl.create(:shelter1, :name => "避難所名１", :shelter_code => "識別番号１")
      @shelter2 = FactoryGirl.create(:shelter1, :name => "避難所名２", :shelter_code => "識別番号２")
      @shelter1.opened_hm = "12:13"
      @shelter2.closed_hm = "10:11"
      @shelter1.save
      @shelter2.save
    end
    it "return error specified label value" do
      ret = SheltersHelper.error_messages_for_shelters([@shelter1, @shelter2])
      ret.should == "<div id='errorExplanation'><ul>\n<li>避難所名&quot;避難所名１&quot;の開設日時（年月日） を入力してください。</li>\n<li>避難所名&quot;避難所名２&quot;の閉鎖日時（年月日） を入力してください。</li>\n</ul></div>\n"
      
    end
  end
  
  
end

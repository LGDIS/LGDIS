require 'spec_helper'
describe Constant do
  describe "#hash_for_table" do
    before do
      FactoryGirl.create(:constant1_1)
      FactoryGirl.create(:constant1_2)
      FactoryGirl.create(:constant2_1)
      FactoryGirl.create(:constant2_2)
      FactoryGirl.create(:constant2_3)
      FactoryGirl.create(:constant3_1)
    end
    it "get constant hash specified table_name" do
      test_hash = {
                    "type1"=>{"1"=>"text1_1", "0"=>"text1_2"}, 
                    "type2"=>{"1"=>"text2_1", "2"=>"text2_2", "3"=>"text2_3"}, 
                    "type3"=>{"1"=>"text3_1"}
                  }
      constant_hash = Constant.hash_for_table('test')
      
      constant_hash.should == test_hash
    end
  end
end

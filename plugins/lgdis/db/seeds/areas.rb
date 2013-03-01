# encoding: utf-8
Area.delete_all # 全件削除

Area.create(:area_code => '1', :name => '石巻地区', :remarks => '', :polygon => '{}')
Area.create(:area_code => '2', :name => '河北地区', :remarks => '', :polygon => '{}')
Area.create(:area_code => '3', :name => '雄勝地区', :remarks => '', :polygon => '{}')
Area.create(:area_code => '4', :name => '河南地区', :remarks => '', :polygon => '{}')
Area.create(:area_code => '5', :name => '桃生地区', :remarks => '', :polygon => '{}')
Area.create(:area_code => '6', :name => '北上地区', :remarks => '', :polygon => '{}')
Area.create(:area_code => '7', :name => '牡鹿地区', :remarks => '', :polygon => '{}')

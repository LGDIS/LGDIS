# -*- coding:utf-8 -*-
FactoryGirl.define do
  factory :constant1_1, :class => "Constant" do 
    kind1          'TD'
    kind2          'test'
    kind3          'type1'
    text           'text1_1'
    value          '1'
    _order         '1'
  end

  factory :constant1_2, :class => "Constant" do 
    kind1          'TD'
    kind2          'test'
    kind3          'type1'
    text           'text1_2'
    value          '0'
    _order         '2'
  end

  factory :constant2_1, :class => "Constant" do 
    kind1          'TD'
    kind2          'test'
    kind3          'type2'
    text           'text2_1'
    value          '1'
    _order         '1'
  end

  factory :constant2_2, :class => "Constant" do 
    kind1          'TD'
    kind2          'test'
    kind3          'type2'
    text           'text2_2'
    value          '2'
    _order         '2'
  end

  factory :constant2_3, :class => "Constant" do 
    kind1          'TD'
    kind2          'test'
    kind3          'type2'
    text           'text2_3'
    value          '3'
    _order         '3'
  end

  factory :constant3_1, :class => "Constant" do 
    kind1          'TD'
    kind2          'test'
    kind3          'type3'
    text           'text3_1'
    value          '1'
    _order         '1'
  end
end

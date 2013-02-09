# -*- coding:utf-8 -*-
FactoryGirl.define do
  factory :issue_geography1, :class => "IssueGeography" do 
    #id
    issue_id 1
    datum    'D'*10
    location 'L'*100
    point    '(1,2)'
    line     '((2,3),(3,4),(4,5),(5,6))'
    polygon  '((6,6),(7,7),(6,7),(7,6))'
    remarks  'R'*255
  end
end


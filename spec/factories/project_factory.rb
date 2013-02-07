# -*- coding:utf-8 -*-
FactoryGirl.define do
  factory :project1, :class => Project do 
    name           'NAME'
    description    'DESCRIPTION'
    homepage       'HOMEPAGE'
    is_public      true
#    parent_id      10
#    created_on     a
#    updated_on     a
#    identifier     a
    status         1
#    lft            1
#    rgt            1
  end
end

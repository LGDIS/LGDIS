# -*- coding:utf-8 -*-
FactoryGirl.define do
  factory :issue1, :class => "Issue" do 
    #id
    tracker_id         1
    project_id         1
    subject            "SUBJECT"
    description        "DESCRIPTION"
    #due_date
    #category_id
    status_id          1
    #assigned_to_id
    priority_id        1
    #fixed_version_id
    author_id          1
    lock_version       1
    #created_on
    #updated_on
    #start_date
    done_ratio         1
    #estimated_hours
    #parent_id
    #root_id
    #lft
    #rgt
    is_private         true
    #xml_controlxml
    #xml_control_status
    #xml_control_editorialoffice
    #xml_control_publishingoffice
    #xml_control_causecharacter
    #xml_control_applycharacter
    #xml_head
    #xml_head_title
    #xml_head_reportdatetime
    #xml_head_targetdatetime
    #xml_head_targetdtdubious
    #xml_head_targetduration
    #xml_head_validdatetime
    #xml_head_eventid
    #xml_head_infotype
    #xml_head_serial
    #xml_head_infokind
    #xml_head_infokindversion
    #xml_head_textcharacter
    #xml_bodyr
  end
end
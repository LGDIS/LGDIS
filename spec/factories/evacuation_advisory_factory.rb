# -*- coding:utf-8 -*-
FactoryGirl.define do
  factory :evacuation_advisory1, :class => "EvacuationAdvisory" do
    sort_criteria                   '2'
    issueorlift                     '1'
    area                            '名称16'
#     area_kana                       
    district                        '2'
#     issued_at                       
#     changed_at                      
#     lifted_at                       
    households                      
    head_count                      
    identifier                      '04202E00000000000006'
#     category                        
#     cause                           
    advisory_type                   '3'
#     staff_no                        
#     full_name                       
#     alias                           
#     headline                        
#     message                         
#     emergency_hq_needed_prefecture  
#     emergency_hq_needed_city        
#     alert                           
#     alerting_area                   
#     siren_area                      
#     evacuation_order                
#     evacuate_from                   
#     evacuate_to                     
#     evacuation_steps_by_authorities 
#     remarks                         
#     deleted_at                      
#     created_at                      
#     updated_at                      
  end
end


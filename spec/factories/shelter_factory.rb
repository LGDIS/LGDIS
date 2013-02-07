# -*- coding:utf-8 -*-
FactoryGirl.define do
  factory :shelter1, :class => "Shelter" do
    project_id                           1
    disaster_code                        2
    name                                 '名前'
    name_kana                            'カナ'
    address                              '住所'
    phone                                '0312345678'
    fax                                  '0312345679'
#    e_mail                               
#    person_responsible                   
    shelter_type                         '1'
#    shelter_type_detail                  
    shelter_sort                         '1'
#    opened_at                            
#    closed_at                            
#    capacity                             
#    status                               
#    head_count                           
#    head_count_voluntary                 
#    households                           
#    households_voluntary                 
#    checked_at                           
    shelter_code                         '避難所識別番号'
#    manager_code                         
#    manager_name                         
#    manager_another_name                 
#    reported_at                          
#    building_damage_info                 
#    electric_infra_damage_info           
#    communication_infra_damage_info      
#    other_damage_info                    
#    usable_flag                          
#    openable_flag                        
#    injury_count                         
#    upper_care_level_three_count         
#    elderly_alone_count                  
#    elderly_couple_count                 
#    bedridden_elderly_count              
#    elderly_dementia_count               
#    rehabilitation_certificate_count     
#    physical_disability_certificate_count
#    note                                 
#    deleted_at                           
#    created_at                           
#    updated_at                           


  end
end


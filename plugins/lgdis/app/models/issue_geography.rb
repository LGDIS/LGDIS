class IssueGeography < ActiveRecord::Base
  unloadable
  
  belongs_to :issue
  
  attr_accessible :datum,:location,:point,:line,:polygon,:remarks
  
  validates :datum,
                :length => {:maximum => 10}
  validates :location,
                :length => {:maximum => 100}
  validates :remarks,
                :length => {:maximum => 255}
end

class IssueGeography < ActiveRecord::Base
  unloadable

  belongs_to :issue
  attr_accessible :id,:issue_id,:datum,:location,:point,:line,:polygon,:remarks,
                  :as => :issue
end

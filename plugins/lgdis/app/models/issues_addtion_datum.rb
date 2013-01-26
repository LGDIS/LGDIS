class IssuesAddtionDatum < ActiveRecord::Base
  unloadable
  belongs_to :issue
  attr_accessible :id,:issue_id,:geodetic_datum,:latitude,:longitude,:address,:remarks,
                  :as => :issue
end

class EditionManagement < ActiveRecord::Base
  unloadable

  attr_accessible :project_id, :tracker_id, :issue_id, :edition_num,
                  :status, :uuid, :delivery_place_id
end

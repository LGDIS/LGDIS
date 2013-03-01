class Area < ActiveRecord::Base
  attr_accessible :area_code, :name, :remarks, :polygon

  validates :area_code,
              :length => {:maximum => 2}
  validates :name,
              :length => {:maximum => 30}
  validates :remarks,
              :length => {:maximum => 256}
end

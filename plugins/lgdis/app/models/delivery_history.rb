class DeliveryHistory < ActiveRecord::Base
  unloadable

  belongs_to :issue
end

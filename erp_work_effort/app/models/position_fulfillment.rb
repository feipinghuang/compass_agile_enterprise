class PositionFulfillment < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by

  belongs_to :held_by_party, class_name: "Party"
  belongs_to :position

end
